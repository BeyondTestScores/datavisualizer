class Response < ApplicationRecord
  belongs_to :survey
  belongs_to :school_tree_category_question

  after_commit :update_totals, on: :create

  private
  def update_totals
    school_tree_category_question.update_totals
  end
end
