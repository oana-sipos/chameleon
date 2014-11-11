class Invitation < ActiveRecord::Base
  belongs_to :event
  belongs_to :user
end
