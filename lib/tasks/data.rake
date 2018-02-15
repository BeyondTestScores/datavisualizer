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
end
