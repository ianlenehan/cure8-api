class Group < ApplicationRecord
  validates :name, presence: :true

  def members
    User.find(member_ids)
  end
end
