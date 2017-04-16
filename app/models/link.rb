class Link < ApplicationRecord
  has_many :users, through: :curations
  has_and_belongs_to_many :tags
end
