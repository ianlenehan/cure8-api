class Link < ApplicationRecord
  has_many :users, through: :curations

  def curations
    Curation.where(link_id: self.id)
  end

  def archived_curations
    Curation.where(link_id: self.id).where.not(status: 'new')
  end
end
