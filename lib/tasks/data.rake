# PSQL: /Applications/Postgres.app/Contents/Versions/9.5/bin/psql -h localhost
require 'csv'
require_relative './response_loader.rb'

namespace :data do
  desc "Load in all data"
  task load: :environment do
    ResponseLoader.new.tap do |loader|
      loader.load_categories
      loader.load_questions
      loader.load_responses
    end
  end

  desc 'Load data for one sample school'
  task load_sample: :environment do
    ResponseLoader.new.tap do |loader|
      loader.load_categories
      loader.load_questions
      loader.load_responses(school_names_whitelist: ['Vinson-Owen Elementary School'])
    end
  end
end
