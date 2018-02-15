# edcontext-open

This project contains three pieces:
- A webapp for visualizing and understanding MCIEA survey data
- Tasks for processing and indexing raw survey data
- Experimental work to conduct survey samples via text message

This is a Rails project, deployed on Heroku.

## Features
- Browsing the list of districts and schools (logged in)
- Creating and editing the list of districts and schools (admin)
- 

## Local development
```
$ bundle install
$ bundle exec rake data:load
```

## Seeding
```
user = User.create(email: 'demo@demo.edcontext.org', password: '123456')
```


## Data
Postgres is the primary data store for the webapp, but the raw survey data is stored in `.json` and `.csv` files.  These are collected offline, and then processed by the rake tasks to load that data into Postgres for use by the webapp.

There are several different kinds of data needed:
- `measures.json`
- `questions.json`
- `student_responses.csv`
- `teacher_responses.csv`


## Deployment


## Path to open source
- Personal phone numbers in code - these are removed (`seed.rb`)
- API keys in code - these are removed (`attempts_controller.rb`)


## Data
- Unable to find questions
- Remove `.csv` files?
- Stopped at `DATAMSG: PROCESSING ROW: 22090 OUT OF 28086 ROWS: 1.415591 - Total: 4066.368556 - 355933.631428 TO GO / 100000 ROWS TO GO`
- Then ran `bundle exec rake data:load_responses`
- Demo data for one school instead?  Changed to whitelist


## Making site navigable
- loading data - uncomment and split to bulk
- creating new admin user manually
- moving `#verify_super_admin` to `application_controller`, adding it for `/admin` pages
- `welcome/index.html.haml` to remove commented code and require login
- Login goes to `/user`, add in link to home page there
- Moved seed code into `pilot_parent_test.rake`, removed individual names and phone numbers
- Added `recipients` and `recipient_lists` links to `school/show.html.haml`
- Added `import` link to `recipients` page
- Added `index` action and view for school schedules
- Edit questions without school_id
- Deleted API keys and numbers in `attempts_controller.rb`


## Major Issues
- loading data is slow!
- What are all the recipients?
- can't get categories pages to show questions
- looks like computation is inverted for some questions like `http://localhost:3000/schools/vinson-owen-elementary-school/categories/student-emotional-safety`

## Minor Issues
- back link not working editing schools and districts
- superadmin is done by user id
- no schools for default user?
- endpoints for school/categories, school/questions
- attempts route and controller commented out
