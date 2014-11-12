class User < ActiveRecord::Base
  has_many :invitations
  has_many :events, through: :invitations
  has_many :feedbacks
  has_many :events, through: :feedbacks

  has_secure_password

  def full_name
  	([first_name, last_name].compact-['']).join(' ')
  end
	  
end
