class Survey < ApplicationRecord

  has_many :survey_questions, dependent: :destroy
  has_many :questions, through: :survey_questions, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1 }

  after_create :create_survey_monkey_survey

  after_commit :sync_with_survey_monkey, on: :create
  after_commit :sync_with_survey_monkey, on: :update

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
      conn.headers['Authorization'] = "bearer #{Rails.application.credentials.dig(:surveymonkey)[:access_token]}"
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
  end

  def update_survey_monkey(updates)
    return {} if survey_monkey_id.blank?
    surveyMonkeyConnection.patch("surveys/#{survey_monkey_id}", updates.to_json)
  end

  def create_survey_monkey_question(survey_question)
    page_title = survey_question.question.category.name
    page = survey_monkey_pages.find do |p|
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

    survey_question.update(survey_monkey_id: response.body['id'], survey_monkey_page_id: page["id"])
    sync_with_survey_monkey
  end

  def update_survey_monkey_question(survey_question)
    page_id = survey_question.survey_monkey_page_id
    question_id = survey_question.survey_monkey_id

    if survey_question.question.category_id_previously_changed?
      surveyMonkeyConnection.delete(
        "surveys/#{survey_monkey_id}/pages/#{page_id}/questions/#{question_id}"
      )

      create_survey_monkey_question(survey_question)
    else
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
    pages = survey_monkey_pages
    if name != details['title']
      update_survey_monkey({
        "title": name
      })
    end

    page_count = pages.length
    pages.each do |page|
      next if SurveyQuestion.on_page(page["id"]).present?
      if page_count > 1 #need at least one page on survey monkey
        remove_survey_monkey_page(page["id"])
        page_count -= 1
      end
    end
  end

end
