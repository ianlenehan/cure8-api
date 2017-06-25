class Link < ApplicationRecord
  has_many :users, through: :curations
  has_and_belongs_to_many :tags

  def curations
    Curation.where(link_id: self.id)
  end
end
