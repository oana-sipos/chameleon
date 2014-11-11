class Event < ActiveRecord::Base
  has_many :invitations
  has_many :users, through: :invitations
end
