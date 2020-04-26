ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'capybara/rails'
require 'webmock/minitest'
require 'capybara/webmock'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

module SurveyMonkeyHelper

  DEFAULT_PAGE_ID = 'DEFAULT'

  def assert_requests(requests)
    requests.each do |request|
      assert_requested request[:method], request[:url], body: request[:body], times: request[:times]
    end
  end

  def survey_monkey_mock(method: :get, url: "surveys", body: nil, responses: [], times: 1, times_out: false)
    with = {headers: {
      'Content-Type' => 'application/json',
      'Authorization' => "bearer #{Rails.application.credentials.dig(:test)[:surveymonkey][:access_token]}"
    }}

    with[:body] = body.to_json if body != nil

    full_url = "https://api.surveymonkey.com/v3/#{url}"
    stub = stub_request(method, full_url).with(with)

    responses.each do |response|
      stub.to_return(status: 200, body: response.to_json, headers: {'Content-Type'=>'application/json'}).then
    end

    if times_out
      stub.to_timeout
    end

    return {method: method, url: full_url, body: with[:body], times: times}
  end

  def pages(survey_questions: nil, pages: nil, default_page: false)
    pages ||= []
    if default_page || (pages.empty? && survey_questions.empty?)
      pages << {"id": DEFAULT_PAGE_ID, "title": ""}
    end

    (survey_questions || []).each do |survey_question|
      page_id = survey_question.survey_monkey_page_id
      id = survey_question.survey_monkey_id
      question = survey_question.question
      page_title = survey_question.category.name

      index = pages.index { |p| p["id"] == page_id }
      if index.nil?
        pages << {"id": page_id, "title": page_title, 'questions': []}
        index = pages.length - 1
      end

      pages[index][:questions] << {
        "id": id,
        "headings": [{
          "heading": question.text
        }],
        "answers": {
          "choices": [
            {"text": question.option1},
            {"text": question.option2},
            {"text": question.option3},
            {"text": question.option4},
            {"text": question.option5}
          ]
        }
      }
    end
    pages
  end

  def details(survey: nil, survey_questions: nil, pages: nil, default_page: false)
    return {} if survey.nil?
    result = {"id": survey.survey_monkey_id, "title": survey.name}

    result["pages"] = pages(
      survey_questions: survey_questions || survey.school_tree_category_questions,
      pages: pages,
      default_page: default_page
    )

    return result
  end
end

module AuthHelper
  def authorized_headers
    return {
      Authorization: ActionController::HttpAuthentication::Basic.encode_credentials(
        Rails.application.credentials.test[:authentication][:admin][:username],
        Rails.application.credentials.test[:authentication][:admin][:password]
      )
    }
  end
end

class ActionDispatch::IntegrationTest
  include SurveyMonkeyHelper
  include AuthHelper
end

class ActiveSupport::TestCase
  include SurveyMonkeyHelper
  include AuthHelper
end


class SampleSurvey
  def details
    {
      "title"=>"Test",
      "nickname"=>"",
      "language"=>"en",
      "folder_id"=>"0",
      "category"=>"",
      "question_count"=>4,
      "page_count"=>2,
      "response_count"=>0,
      "date_created"=>"2020-03-23T11:55:00",
      "date_modified"=>"2020-03-23T11:55:00",
      "id"=>"280364874",
      "buttons_text"=>{
        "next_button"=>"Next",
        "prev_button"=>"Prev",
        "done_button"=>"Done",
        "exit_button"=>"Exit"
      },
      "is_owner"=>true,
      "footer"=>true,
      "custom_variables"=>{},
      "href"=>"https://api.surveymonkey.com/v3/surveys/280364874",
      "analyze_url"=>"https://www.surveymonkey.com/analyze/HMV5Wy46RB71HeuQPSxeD_2F9GmJW59SwL7_2B_2Fy6kON890_3D",
      "edit_url"=>"https://www.surveymonkey.com/create/?sm=HMV5Wy46RB71HeuQPSxeD_2F9GmJW59SwL7_2B_2Fy6kON890_3D",
      "collect_url"=>"https://www.surveymonkey.com/collect/list?sm=HMV5Wy46RB71HeuQPSxeD_2F9GmJW59SwL7_2B_2Fy6kON890_3D",
      "summary_url"=>"https://www.surveymonkey.com/summary/HMV5Wy46RB71HeuQPSxeD_2F9GmJW59SwL7_2B_2Fy6kON890_3D",
      "preview"=>"https://www.surveymonkey.com/r/Preview/?sm=6pa1SeftMqbHo9_2BxjxjLnoxIozPIx9vkKYqy5pmMmZuCENCFICkGVG2T9xySBqZs",
      "pages"=>[
        {
          "title"=>"R2AA",
          "description"=>"",
          "position"=>1,
          "question_count"=>3,
          "id"=>"117069767",
          "href"=>"https://api.surveymonkey.com/v3/surveys/280364874/pages/117069767",
          "questions"=>[
            {
              "id"=>"439553905",
              "position"=>1,
              "visible"=>true,
              "family"=>"single_choice",
              "subtype"=>"vertical",
              "sorting"=>nil,
              "required"=>nil,
              "validation"=>nil,
              "forced_ranking"=>false,
              "headings"=>[
                {
                  "heading"=>"What is the answer to this other question?"
                }
              ],
              "href"=>"https://api.surveymonkey.com/v3/surveys/280364874/pages/117069767/questions/439553905",
              "answers"=>{
                "choices"=>[
                  {
                    "position"=>1,
                    "visible"=>true,
                    "text"=>"Option 1",
                    "quiz_options"=>{
                      "score"=>0
                    },
                    "id"=>"2915141847"
                  }, {
                    "position"=>2,
                    "visible"=>true,
                    "text"=>"Option 2",
                    "quiz_options"=>{
                      "score"=>0
                    },
                    "id"=>"2915141848"
                  }, {
                    "position"=>3,
                    "visible"=>true,
                    "text"=>"Option 3",
                    "quiz_options"=>{
                      "score"=>0
                    },
                    "id"=>"2915141849"
                  }, {
                    "position"=>4,
                    "visible"=>true,
                    "text"=>"Option 4",
                    "quiz_options"=>{
                      "score"=>0
                    },
                    "id"=>"2915141850"
                  }, {
                    "position"=>5,
                    "visible"=>true,
                    "text"=>"Option 5",
                    "quiz_options"=>{
                      "score"=>0
                    },
                    "id"=>"2915141851"
                  }
                ]
              }
            }, {
              "id"=>"439553889",
              "position"=>2,
               "visible"=>true,
               "family"=>"single_choice",
               "subtype"=>"vertical",
               "sorting"=>nil,
               "required"=>nil,
               "validation"=>nil,
               "forced_ranking"=>false,
               "headings"=>[{"heading"=>"What is the answer to this
      question? (EDITED)"}],
      "href"=>"https://api.surveymonkey.com/v3/surveys/280364874/pages/117069767/questions/439553889",
      "answers"=>{"choices"=>[{"position"=>1, "visible"=>true, "text"=>"Option 1",
      "quiz_options"=>{"score"=>0}, "id"=>"2915141722"}, {"position"=>2,
      "visible"=>true, "text"=>"Option 2", "quiz_options"=>{"score"=>0},
      "id"=>"2915141723"}, {"position"=>3, "visible"=>true, "text"=>"Option 3",
      "quiz_options"=>{"score"=>0}, "id"=>"2915141724"}, {"position"=>4,
      "visible"=>true, "text"=>"Option 4", "quiz_options"=>{"score"=>0},
      "id"=>"2915141725"}, {"position"=>5, "visible"=>true, "text"=>"Option 5
      (EDITED)", "quiz_options"=>{"score"=>0}, "id"=>"2915141726"}]}},
      {"id"=>"439553874", "position"=>3, "visible"=>true, "family"=>"single_choice",
      "subtype"=>"vertical", "sorting"=>nil, "required"=>nil, "validation"=>nil,
      "forced_ranking"=>false, "headings"=>[{"heading"=>"What would another R2AA
      question be?"}],
      "href"=>"https://api.surveymonkey.com/v3/surveys/280364874/pages/117069767/questions/439553874",
      "answers"=>{"choices"=>[{"position"=>1, "visible"=>true, "text"=>"1",
      "quiz_options"=>{"score"=>0}, "id"=>"2915141603"}, {"position"=>2,
      "visible"=>true, "text"=>"2", "quiz_options"=>{"score"=>0}, "id"=>"2915141604"},
      {"position"=>3, "visible"=>true, "text"=>"3", "quiz_options"=>{"score"=>0},
      "id"=>"2915141605"}, {"position"=>4, "visible"=>true, "text"=>"4",
      "quiz_options"=>{"score"=>0}, "id"=>"2915141606"}, {"position"=>5,
      "visible"=>true, "text"=>"5", "quiz_options"=>{"score"=>0},
      "id"=>"2915141607"}]}}]}, {"title"=>"Root 1", "description"=>"", "position"=>2,
      "question_count"=>1, "id"=>"117069782",
      "href"=>"https://api.surveymonkey.com/v3/surveys/280364874/pages/117069782",
      "questions"=>[{"id"=>"439553918", "position"=>1, "visible"=>true,
      "family"=>"single_choice", "subtype"=>"vertical", "sorting"=>nil,
      "required"=>nil, "validation"=>nil, "forced_ranking"=>false,
      "headings"=>[{"heading"=>"Root Question"}],
      "href"=>"https://api.surveymonkey.com/v3/surveys/280364874/pages/117069782/questions/439553918",
      "answers"=>{"choices"=>[{"position"=>1, "visible"=>true, "text"=>"1",
      "quiz_options"=>{"score"=>0}, "id"=>"2915141958"}, {"position"=>2,
      "visible"=>true, "text"=>"2", "quiz_options"=>{"score"=>0}, "id"=>"2915141959"},
      {"position"=>3, "visible"=>true, "text"=>"3", "quiz_options"=>{"score"=>0},
      "id"=>"2915141960"}, {"position"=>4, "visible"=>true, "text"=>"4",
      "quiz_options"=>{"score"=>0}, "id"=>"2915141961"}, {"position"=>5,
      "visible"=>true, "text"=>"5", "quiz_options"=>{"score"=>0},
      "id"=>"2915141962"}]}}]}]
    }
  end
end
