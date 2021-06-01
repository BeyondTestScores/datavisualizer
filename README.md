# Getting Started

- If you don't have a GitHub account then register one (here)[https://github.com/join].
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
- In the "Scopes" section select the following scopes:
- Create/Modify Surveys
- Create/Modify Collections
- Create/Modify Responses
- View Response Details
- View Webhooks
- View Surveys
- View Collectors
- View Responses
- Create/Modify Webhooks
- In the "Credentials" section find the Access Token.
- Back In Heroku copy it and add it to the config vars in Heroku like you did "AUTH_USERNAME" above. Call is "SURVEYMONKEY_ACCESS_TOKEN"
- Add another config var that looks like "SURVEYMONKEY_CALLBACK_URL" and give it the domain for your website (unless you are using a custom domain this would be https://[NAME OF YOUR APP].herokuapp.com/)
- Click "Open App" at the top of the page to open the app.

# Run Tests

bundle
yarn
rails test (requires survey monkey account)
rails test:system

# Deploying (CI tests are running)

If Heroku has been set up correctly then tests and deployment should happen automatically on git push

# Get latest database dump

rm latest.dump
sudo heroku pg:backups:capture
sudo heroku pg:backups:download
pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d edcontext_development latest.dump

# Console

sudo heroku run console

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

(Heroku)[]

(Survey Monkey)[https://www.surveymonkey.com/dashboard]
