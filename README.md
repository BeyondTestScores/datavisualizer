# Getting Started

- Clone this repository
- Run it locally using the instructions below
- Register an account on [Heroku](https://www.heroku.com/)
- Click "Create New App"
- Give it a name
- Click "Create App"

Edit Credentials (master key in 1Password - contains Survey Monkey credentials):

EDITOR="code --wait" bin/rails credentials:edit

# Run Tests

bundle
yarn
rails test (requires survey monkey account)
rails test:system

# Deploying (CI tests are running)

git push && git push heroku MTA:master

# Get latest database dump

rm latest.dump
sudo heroku pg:backups:capture
sudo heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d edcontext_development latest.dump

# Console

sudo heroku run console

# Migration

sudo heroku run rails db:migrate

# Creating SurveyMonkey Surveys from Existing Surveys

Survey.all.each do |s|
s.update(survey_monkey_id: nil)
s.create_survey_monkey_survey
s.school_tree_category_questions.each do |stcq|
stcq.update(survey_monkey_page_id: nil)
s.create_survey_monkey_question(stcq)
sleep(1)
end
sleep(1)
end

# Links

https://www.surveymonkey.com/dashboard

https://beyond-test-scores-test.herokuapp.com/

https://beyond-test-scores-test.herokuapp.com/admin

https://mciea-dashboard.herokuapp.com/
