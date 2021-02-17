$survey_monkey_disabled = false

class Survey < ApplicationRecord

  enum kind: Question.kinds

  belongs_to :tree
  belongs_to :school
  has_many :school_tree_category_questions, dependent: :destroy

  validates :name, presence: true, length: { minimum: 1 }

  after_create :create_survey_monkey_survey 
  after_commit :sync_with_survey_monkey, on: :create 
  after_update_commit :sync_with_survey_monkey 
  before_destroy :delete_survey_monkey_survey 

  scope :for_school, ->(school){ where(school: school) }
  scope :for_tree, -> (tree) { where(tree: tree) }
  scope :for_kind, -> (kind) { where(kind: kind) }

  def to_s
    "#{name} (#{school.name})"
  end

  def has_question(question)
    questions.include?(question)
  end

  def survey_monkey_connection
    return if $survey_monkey_disabled

    Faraday.new('https://api.surveymonkey.com/v3') do |conn|
      conn.adapter Faraday.default_adapter
      conn.response :json, :content_type => /\bjson$/
      conn.headers['Authorization'] = "bearer #{Rails.application.credentials.dig(Rails.env.to_sym)[:surveymonkey][:access_token]}"
      conn.headers['Content-Type'] = 'application/json'
    end
  end

  def survey_monkey_responses
    return if $survey_monkey_disabled
    return if survey_monkey_id.blank?
    survey_monkey_connection.get("surveys/#{survey_monkey_id}/responses").body
  end

  def survey_monkey_pages_structure
    return if $survey_monkey_disabled

    pages = {}
    questions.each_with_index do |question, index|
      pages[question.category.name] ||= {title: question.category.name, questions: []}
      pages[question.category.name][:questions] << question.survey_monkey_question(index)
    end
    return pages
  end

  def create_survey_monkey_survey
    return if $survey_monkey_disabled

    return if survey_monkey_id.present?

    response = survey_monkey_connection.post('surveys', {
      "title":"#{name}"#,
      #"pages": survey_monkey_pages_structure.values
    }.to_json)

    update(survey_monkey_id: response.body['id'])
  end

  def delete_survey_monkey_survey
    return if $survey_monkey_disabled

    return if survey_monkey_id.blank?

    survey_monkey_connection.delete("surveys/#{survey_monkey_id}")
  end

  def survey_monkey_details
    return if $survey_monkey_disabled

    return {} if survey_monkey_id.blank?

    survey_monkey_connection.get("surveys/#{survey_monkey_id}/details").body
  end

  def survey_monkey_pages
    return if $survey_monkey_disabled

    return {} if survey_monkey_id.blank?

    survey_monkey_connection.get("surveys/#{survey_monkey_id}/pages").body["data"]
  end

  def remove_survey_monkey_page(page_id)
    return if $survey_monkey_disabled

    return {} if survey_monkey_id.blank?

    survey_monkey_connection.delete("surveys/#{survey_monkey_id}/pages/#{page_id}")
    sync_with_survey_monkey
  end

  def update_survey_monkey(updates)
    return if $survey_monkey_disabled

    return {} if survey_monkey_id.blank?

    survey_monkey_connection.patch("surveys/#{survey_monkey_id}", updates.to_json)
  end

  def create_survey_monkey_question(school_tree_category_question)
    return if $survey_monkey_disabled

    # return if school_tree_category_question.survey_monkey_page_id.present?

    page_title = school_tree_category_question.category.name
    smp = survey_monkey_pages

    return if smp.nil?
    
    page = smp.find do |p|
      p['title'] == page_title
    end

    if page.nil?
      page = survey_monkey_connection.post(
        "surveys/#{survey_monkey_id}/pages",
        {title: page_title}.to_json
      ).body
    end

    response = survey_monkey_connection.post(
      "surveys/#{survey_monkey_id}/pages/#{page["id"]}/questions",
      school_tree_category_question.question.survey_monkey_structure(1).to_json
    )

    smid = response.body['id']
    if (school_tree_category_question.survey_monkey_id != smid || school_tree_category_question.survey_monkey_page_id != page["id"])
      school_tree_category_question.update(
        survey_monkey_id: response.body['id'],
        survey_monkey_page_id: page["id"]
      )
    end

    sync_with_survey_monkey
  end

  def update_survey_monkey_question(school_tree_category_question)
    return if $survey_monkey_disabled

    page_id = school_tree_category_question.survey_monkey_page_id
    question_id = school_tree_category_question.survey_monkey_id

    if school_tree_category_question.category.name_previously_changed?
      survey_monkey_connection.patch(
        "surveys/#{survey_monkey_id}/pages/#{page_id}",
        {"title": school_tree_category_question.category.name}.to_json
      )
    end

    if school_tree_category_question.tree_category_question.tree_category_id_previously_changed?
      survey_monkey_connection.delete(
        "surveys/#{survey_monkey_id}/pages/#{page_id}/questions/#{question_id}"
      )

      # school_tree_category_question.survey_monkey_page_id = nil
      create_survey_monkey_question(school_tree_category_question)
      return
    elsif school_tree_category_question.question.previous_changes.keys.present?
      survey_monkey_connection.patch(
        "surveys/#{survey_monkey_id}/pages/#{page_id}/questions/#{question_id}",
        school_tree_category_question.question.survey_monkey_structure(1).to_json
      )
    end

    sync_with_survey_monkey
  end

  def remove_survey_monkey_question(school_tree_category_question)
    return if $survey_monkey_disabled

    page_id = school_tree_category_question.survey_monkey_page_id
    question_id = school_tree_category_question.survey_monkey_id
    survey_monkey_connection.delete(
      "surveys/#{survey_monkey_id}/pages/#{page_id}/questions/#{question_id}"
    )
    sync_with_survey_monkey
  end

  def create_webhook
    callback_url = Rails.application.credentials.dig(Rails.env.to_sym)[:url]
    return if callback_url.blank?
    
    endpoint = "webhooks"
    webhooks = survey_monkey_connection.get(endpoint).body["data"]

    object_ids = []
    if (webhooks)
      endpoint = "webhooks/#{webhooks.first["id"]}"
      webhook = survey_monkey_connection.get(endpoint).body
      object_ids = webhook["object_ids"] || []
      return if object_ids.include?(survey_monkey_id)
    end

    object_ids << survey_monkey_id

    data = {
      "name": "Survey Responses Webhook", 
      "event_type": "response_completed", 
      "object_type": "survey",
      "object_ids": object_ids,
      "subscription_url": callback_url + "survey_responses"
    }.to_json
    
    if webhooks.present?
      survey_monkey_connection.put(endpoint, data)
    else
      survey_monkey_connection.post(endpoint, data)
    end
  end

  def sync_with_survey_monkey
    return if $survey_monkey_disabled

    create_webhook

    details = survey_monkey_details

    if name != details['title']
      update_survey_monkey({
        "title": name
      })
    end

    sm_pages = details['pages'] || []
    sm_pages.each do |sm_page|
      sm_questions = sm_page['questions'] || []

      all_questions_removed = true
      on_page_stcq = school_tree_category_questions.on_page(sm_page['id'])

      if on_page_stcq.present?
        category = on_page_stcq.first.category
        if category.name != sm_page["title"]
          survey_monkey_connection.patch(
            "surveys/#{details['id']}/pages/#{sm_page['id']}",
            {title: category.name}.to_json
          )
        end
      end

      sm_questions.each do |sm_question|
        stcq = on_page_stcq.find do |stcq|
          stcq.question.text == sm_question["headings"].first['heading']
        end

        if stcq.nil?
          survey_monkey_connection.delete(
            "surveys/#{details['id']}/pages/#{sm_page['id']}/questions/#{sm_question['id']}"
          )
        else
          all_questions_removed = false
          stcq.update(survey_monkey_id: sm_question['id'], survey_monkey_page_id: sm_page['id'])
        end
      end

      if sm_questions.blank? || all_questions_removed
        survey_monkey_connection.delete(
          "surveys/#{details['id']}/pages/#{sm_page['id']}"
        )
      end
    end
  end

end
