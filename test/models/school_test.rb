require 'test_helper'

class SchoolTest < ActiveSupport::TestCase
  # test "creates school_tree_categories for all categories marked as admininistrative measures on create" do
  #   Survey.skip_callback(:commit, :after, :sync_with_survey_monkey, raise: false)
  #   Survey.skip_callback(:create, :after, :create_survey_monkey_survey, raise: false)
  #   SchoolTreeCategoryQuestion.skip_callback(:commit, :after, :create_survey_monkey, raise: false)

  #   administrative_measure_count = Category.administrative_measure.count
  #   school_tree_category_count = SchoolTreeCategory.count

  #   School.create(name: "New School")

  #   assert_equal school_tree_category_count + administrative_measure_count, SchoolTreeCategory.count

  #   SchoolTreeCategoryQuestion.set_callback(:commit, :after, :create_survey_monkey) 
  #   Survey.set_callback(:commit, :after, :sync_with_survey_monkey) 
  #   Survey.set_callback(:create, :after, :create_survey_monkey_survey) 
  # end

  test "creates all relevant surveys and related models when created" do
    Survey.skip_callback(:commit, :after, :sync_with_survey_monkey, raise: false) do
      Survey.skip_callback(:create, :after, :create_survey_monkey_survey, raise: false) do
        Survey.skip_callback(:destroy, :before, :delete_survey_monkey_survey, raise: false) do
          SchoolTreeCategoryQuestion.skip_callback(:commit, :after, :create_survey_monkey, raise: false) do
            SchoolTreeCategoryQuestion.skip_callback(:destroy, :after, :destroy_survey_monkey, raise: false) do

              survey_count = Survey.count
              school_tree_category_count = SchoolTreeCategory.count
              school_tree_category_question_count = SchoolTreeCategoryQuestion.count

              School.create(name: "New School")

              assert_equal survey_count + schools(:one).surveys.count, Survey.count
              assert_equal school_tree_category_count + TreeCategory.count, SchoolTreeCategory.count
              assert_equal school_tree_category_question_count + TreeCategoryQuestion.count, SchoolTreeCategoryQuestion.count

              School.last.destroy

              assert_equal survey_count, Survey.count
              assert_equal school_tree_category_count, SchoolTreeCategory.count
              assert_equal school_tree_category_question_count, SchoolTreeCategoryQuestion.count
            end
          end
        end
      end
    end
  end
end
