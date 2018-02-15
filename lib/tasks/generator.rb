class Generator
  # district and schools
  DISTRICT_NAMES = ['Townville', 'Cityton']
  SCHOOL_NAMES = ['Alpha Elementary', 'Beta Middle', 'Gamma High', 'Delta K8']

  # how many recipients?
  RECIPIENTS_RANGE = [20, 30]

  # how many questions are asked of each recipient?
  # Recipient.all.map {|r| r.attempts.flat_map(&:question).size }.sort
  QUESTIONS_PER_RECIPIENT = [0, 2, 3, 4, 5, 6, 12, 13, 15, 19, 20, 22, 24, 26, 42, 43, 44, 49, 62, 65, 66, 67, 68, 69, 70]

  # what questions are attempted?
  # Recipient.all.flat_map {|r| r.attempts.flat_map(&:question_id) }.sort.uniq
  # QUESTIONS_ATTEMPTED = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 215, 231]
  # just query all these

  def create_demo_data
    # keep consistent for each use
    rng = Random.new(42)

    # schools and districts
    puts "Creating schools and districts..."
    schools = SCHOOL_NAMES.map do |school_name|
      district_name = DISTRICT_NAMES.sample(random: rng)
      district = District.find_or_create_by!({
        name: district_name,
        state_id: 1
      })
      district.schools.find_or_create_by!(name: school_name)
    end
    puts "Done."

    # recipients
    recipient_count = rng.rand(RECIPIENTS_RANGE[1] - RECIPIENTS_RANGE[0]) + RECIPIENTS_RANGE[0]
    puts "Creating #{recipient_count} recipients..."
    recipient_count.times do |recipient_index|
      respondent_key = rng.rand(36**32).to_s(36)
      recipient_name = "Survey Respondent Id: R_#{respondent_key}"
      school = schools.sample(random: rng)
      recipient = school.recipients.create!(name: recipient_name)

      # questions
      questions_to_ask = QUESTIONS_PER_RECIPIENT.sample(random: rng)
      questions_attempted = Question.all.map(&:id)
      question_ids = questions_attempted.sample(questions_to_ask, random: rng)
      questions = Question.find(question_ids)
      puts "  Creating attempts to #{questions.length} questions for #{recipient_name}..."
      questions.each do |question|
        recipient.attempts.create!({
          question: question,
          answer_index: rng.rand(question.options.size) + 1, # 1-indexed
          responded_at: Time.now
        })
      end
    end
    puts "Done."

    # reindex counts and aggregates
    puts "Indexing recipient counts..."
    Recipient.all.each { |r| r.update_counts }

    puts "Syncing aggregates across schools..."
    categories = Category.all
    schools.each do |school|
      puts("  school: #{school.name}...")
      categories.each do |category|
        school_category = SchoolCategory.for(school, category).first
        if school_category.nil?
          school_category = SchoolCategory.create!(school: school, category: category)
        end
        school_category.sync_aggregated_responses
      end
    end
    puts "Done."
  end
end