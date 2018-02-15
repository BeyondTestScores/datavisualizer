# PSQL: /Applications/Postgres.app/Contents/Versions/9.5/bin/psql -h localhost
require 'csv'
require_relative './response_loader.rb'
require_relative './generator.rb'

namespace :data do
  desc "Load in all data"
  task load: :environment do
    loader = ResponseLoader.new
    loader.load_categories
    loader.load_questions
    loader.load_responses
  end

  desc 'Load data for one sample school'
  task load_sample: :environment do
    loader = ResponseLoader.new
    loader.load_categories
    loader.load_questions
    loader.load_responses(school_names_whitelist: ['Vinson-Owen Elementary School'])
  end

  desc 'Load demo data'
  task generate: :environment do
    loader = ResponseLoader.new
    loader.load_categories
    loader.load_questions

    generator = Generator.new
    generator.create_demo_data
  end

  desc 'Show qualitative comments'
  task qualitative: :environment do
    # what to look for
    comment_question = 'If there is anything you would like us to know about your school that we did not ask about, please tell us.'
    district_question = 'To begin, please select your district.'

    # open csv
    filepath = File.expand_path("../../../data/teacher_responses_2017.csv", __FILE__)
    csv_string = File.read(filepath)
    csv = CSV.parse(csv_string, :headers => true)

    # process
    comments = []
    csv.each_with_index do |row, index|
      respondent_id = nil
      district_name = nil
      school_name = nil
      comment = nil
      row.each do |key, value|
        if key == 'Response ID'
          respondent_id = row['Response ID']
        elsif key == district_question
          district_name = row[district_question]
        elsif key == "Please select your school in #{district_name}."
          school_name = row["Please select your school in #{district_name}."]
        elsif key == comment_question
          comment = row[comment_question]
        end
      end
      next if comment == '-99'

      comments << {
        district_name: district_name,
        school_name: school_name,
        comment: comment
      }
    end

    puts comments.to_json
  end
end