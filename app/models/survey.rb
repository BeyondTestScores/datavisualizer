class Survey < ApplicationRecord

  has_many :survey_questions, dependent: :destroy
  has_many :questions, through: :survey_questions, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1 }

  after_create :create_survey_monkey_survey

  after_commit :sync_with_survey_monkey, on: :create
  after_update_commit :sync_with_survey_monkey

  before_destroy :delete_survey_monkey_survey

  def to_s
    name
  end

  def has_question(question)
    questions.include?(question)
  end

  def category_tree
    tree = {child_categories: []}

    questions.each do |question|
        category = question.category
        question_path = []
        while category
          question_path << category
          category = category.parent_category
        end

        node = tree
        question_path.reverse.each do |category|
          category_hash = node[:child_categories].find { |cc| cc[:category].name == category.name }
          if category_hash.blank?
            category_hash = {category: category, child_categories: []}
            node[:child_categories].push(category_hash)
          end
          node[:child_categories].sort! { |a,b| a[:category].name <=> b[:category].name }
          node = category_hash
        end

        node[:questions] ||= []
        node[:questions] << question
    end

    return tree
  end

  def surveyMonkeyConnection
    Faraday.new('https://api.surveymonkey.com/v3') do |conn|
      conn.adapter Faraday.default_adapter
      conn.response :json, :content_type => /\bjson$/
      conn.headers['Authorization'] = "bearer #{Rails.application.credentials.dig(Rails.env.to_sym)[:surveymonkey][:access_token]}"
      conn.headers['Content-Type'] = 'application/json'
    end
  end

  def survey_monkey_pages_structure
    pages = {}
    questions.each_with_index do |question, index|
      pages[question.category.name] ||= {title: question.category.name, questions: []}
      pages[question.category.name][:questions] << question.survey_monkey_question(index)
    end
    return pages
  end

  def create_survey_monkey_survey
    return if survey_monkey_id.present?

    response = surveyMonkeyConnection.post('surveys', {
      "title":"#{name}"#,
      #"pages": survey_monkey_pages_structure.values
    }.to_json)

    update(survey_monkey_id: response.body['id'])
  end

  def delete_survey_monkey_survey
    return if survey_monkey_id.blank?
    surveyMonkeyConnection.delete("surveys/#{survey_monkey_id}")
  end

  def survey_monkey_details
    return {} if survey_monkey_id.blank?
    surveyMonkeyConnection.get("surveys/#{survey_monkey_id}/details").body
  end

  def survey_monkey_pages
    return {} if survey_monkey_id.blank?
    surveyMonkeyConnection.get("surveys/#{survey_monkey_id}/pages").body["data"]
  end

  def remove_survey_monkey_page(page_id)
    return {} if survey_monkey_id.blank?
    surveyMonkeyConnection.delete("surveys/#{survey_monkey_id}/pages/#{page_id}")
    sync_with_survey_monkey
  end

  def update_survey_monkey(updates)
    return {} if survey_monkey_id.blank?
    surveyMonkeyConnection.patch("surveys/#{survey_monkey_id}", updates.to_json)
  end

  def create_survey_monkey_question(survey_question)
    page_title = survey_question.question.category.name
    smp = survey_monkey_pages
    page = smp.find do |p|
      p['title'] == page_title
    end

    if page.nil?
      page = surveyMonkeyConnection.post(
        "surveys/#{survey_monkey_id}/pages",
        {title: page_title}.to_json
      ).body
    end

    response = surveyMonkeyConnection.post(
      "surveys/#{survey_monkey_id}/pages/#{page["id"]}/questions",
      survey_question.question.survey_monkey_structure(1).to_json
    )

    smid = response.body['id']
    if (survey_question.survey_monkey_id != smid || survey_question.survey_monkey_page_id != page["id"])
      survey_question.update(
        survey_monkey_id: response.body['id'],
        survey_monkey_page_id: page["id"]
      )
    end

    sync_with_survey_monkey
  end

  def update_survey_monkey_question(survey_question)
    page_id = survey_question.survey_monkey_page_id
    question_id = survey_question.survey_monkey_id

    if survey_question.question.category.name_previously_changed?
      surveyMonkeyConnection.patch(
        "surveys/#{survey_monkey_id}/pages/#{page_id}",
        {"title": survey_question.question.category.name}.to_json
      )
    end

    if survey_question.question.category_id_previously_changed?
      surveyMonkeyConnection.delete(
        "surveys/#{survey_monkey_id}/pages/#{page_id}/questions/#{question_id}"
      )

      create_survey_monkey_question(survey_question)
      return
    elsif survey_question.question.previous_changes.keys.present?
      surveyMonkeyConnection.patch(
        "surveys/#{survey_monkey_id}/pages/#{page_id}/questions/#{question_id}",
        survey_question.question.survey_monkey_structure(1).to_json
      )
    end

    sync_with_survey_monkey
  end

  def remove_survey_monkey_question(survey_question)
    response = surveyMonkeyConnection.delete(
      "surveys/#{survey_monkey_id}/pages/#{survey_question.survey_monkey_page_id}/questions/#{survey_question.survey_monkey_id}"
    )
    sync_with_survey_monkey
  end

  def sync_with_survey_monkey
    details = survey_monkey_details

    if name != details['title']
      update_survey_monkey({
        "title": name
      })
    end

    sm_pages = details['pages'] || []
    sm_page_count = sm_pages.length
    sm_pages.each do |sm_page|
      sm_questions = sm_page['questions'] || []

      all_questions_removed = true
      on_page_sq = survey_questions.on_page(sm_page['id']).joins(:question)

      if on_page_sq.present?
        category = on_page_sq.first.question.category
        if category.name != sm_page["title"]
          surveyMonkeyConnection.patch(
            "surveys/#{details['id']}/pages/#{sm_page['id']}",
            {title: category.name}.to_json
          )
        end
      end

      sm_questions.each do |sm_question|
        survey_question = on_page_sq.find do |sq|
          sq.question.text == sm_question["headings"].first['heading']
        end

        if survey_question.nil?
          surveyMonkeyConnection.delete(
            "surveys/#{details['id']}/pages/#{sm_page['id']}/questions/#{sm_question['id']}"
          )
        else
          all_questions_removed = false
          survey_question.update(survey_monkey_id: sm_question['id'], survey_monkey_page_id: sm_page['id'])
        end
      end

      if sm_questions.blank? || all_questions_removed
        surveyMonkeyConnection.delete(
          "surveys/#{details['id']}/pages/#{sm_page['id']}"
        )
      end
    end
  end

end
