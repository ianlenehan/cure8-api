class Link < ApplicationRecord
  has_many :users, through: :curations
  has_many :conversations

  def curations
    Curation.where(link_id: self.id)
  end

  def archived_curations
    Curation.where(link_id: self.id).where.not(status: 'new')
  end

  def owner
    User.find(self.link_owner)
  end
end
