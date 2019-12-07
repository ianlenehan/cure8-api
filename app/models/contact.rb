class Contact < ApplicationRecord
  belongs_to :user

  def linked_user
    User.where(id: linked_user_id)
  end
end
