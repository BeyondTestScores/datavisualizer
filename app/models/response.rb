class Response < ApplicationRecord
  belongs_to :survey
  belongs_to :school_tree_category_question
end
