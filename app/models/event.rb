class Event < ActiveRecord::Base
  has_many :invitations
  has_many :users, through: :invitations
  has_many :feedbacks
  has_many :users, through: :feedbacks
end
