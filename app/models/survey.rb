class Survey < ApplicationRecord

  has_many :survey_questions
  has_many :questions, through: :survey_questions

  validates :name, presence: true, length: { minimum: 1 }

  after_create :create_survey_monkey_survey

  # after_commit :sync_with_survey_monkey

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

  def create_survey_monkey_survey
    response = surveyMonkeyConnection.post('surveys', {"title":"#{name}"}.to_json)
    update(survey_monkey_id: response.body['id'])
  end

end
