# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

- Ruby version

- System dependencies

- Configuration

- Database creation

- Database initialization

- How to run the test suite

- Services (job queues, cache servers, search engines, etc.)

- Deployment instructions

- ...

Getting Started

Edit Credentials (master key in 1Password):

EDITOR="code --wait" bin/rails credentials:edit

Run Tests

bundle
yarn
rails test (requires survey monkey account)
rails test:system

Creating SurveyMonkey Surveys from Existing Surveys

Survey.all.each do |s|
s.update(survey_monkey_id: nil)
s.create_survey_monkey_survey
s.school_tree_category_questions.each do |stcq|
stcq.update(survey_monkey_page_id: nil)
s.create_survey_monkey_question(stcq)
end
end
