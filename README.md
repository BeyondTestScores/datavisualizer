# Getting Started

- Fork this repository
- Run it locally using the instructions below
- Register an account on [Heroku](https://www.heroku.com/)
- Click "Create New App"
- Give it a name
- Click "Create App"
- Click "GitHub: Connect to GitHub" in the "Deployment method" section.
- Select the app you've forked
- Click "Connect"
- Click "Enable Automatic Deploys"
- Click "Deploy Branch"
- Click on "Settings"
- Click on "Reveal Config Vars"
- Add "AUTH_USERNAME" and "AUTH_PASSWORD" and set them to create an admin username and password
- Register an account on [SurveyMonkey](https://www.surveymonkey.com/user/sign-up/?ut_source=homepage&ut_source3=megamenu)
- Click [Upgrade](https://www.surveymonkey.com/pricing/upgrade/) in the top right corner
- Select a plan (any of them should be fine)
- Visit the [Developer Dashboard](https://developer.surveymonkey.com/)
- Give the app a name and select "Private App"
- Then hit "Create App"
- Click "Settings"
- In the "Credentials" section find the Access Token.
- Copy it and add it to the config vars in Heroku like you did "AUTH_USERNAME" above. Call is "SURVEYMONKEY_ACCESS_TOKEN"

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
