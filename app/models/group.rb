class Group < ApplicationRecord
  validates :name, presence: :true
  belongs_to :user

  def is_member?
    if self.user_id
      user = User.find(self.user_id)
      !!user.first_name
    end
  end
end
