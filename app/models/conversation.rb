class Conversation < ApplicationRecord
  has_many :messages, :dependent => :delete_all
  has_and_belongs_to_many :users
  belongs_to :link
end
