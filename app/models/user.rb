class User < ActiveRecord::Base
  has_many :invitations
  has_many :events, through: :invitations
  has_many :feedbacks
  has_many :events, through: :feedbacks

  has_secure_password validations:false # we are rewriting validations by hand below, so we can customize the messages.

  validates :first_name, presence:{message:'Please give us your first name'}

  validates :last_name, presence:{message:'Please give us your last name'}

  validates :email, format:{:with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => "Please enter a valid email address"}

  validate :check_email_duplicates

  validates :password, length:{minimum:6, message:'Your password must have at least 6 characters', if:Proc.new { |u| u.password.present? } }

  validates :terms_of_service, acceptance:{message:'You must accept our Terms of Service.'}

  attr_accessor :skip_password_validation # useful to create users without a password, for instance via Facebook.

  # has_secure_password validations rewritten below:
  validates :password, presence:{message:'Please enter a password. It must have at least 6 characters.'}, on: :create, unless:Proc.new { |u| u.skip_password_validation }
  validates :password, confirmation:{message:"Passwords don't match"}, if: lambda { |u| u.password.present? }
  validates :password_confirmation, presence:{message:'Please enter the password again'},  if: lambda { |u| u.password.present? }
  # end of h_s_p rewrites

  # Generate a string that tries to have the first and last name connected with a whitespace,
  # but also copes with one or both of them missing.
  def full_name
  	([first_name, last_name].compact-['']).join(' ')
  end
	
	# Creates a user based on the hash of information that Facebook sends us.
	# User will have a nil password.
	def self.create_from_facebook(hash)
		self.create facebook_uid: hash['uid'],
                       email: hash['info']['email'],
                  first_name: hash['info']['first_name'],
                   last_name: hash['info']['last_name'],
    skip_password_validation: true
  end

  def self.find_or_create_from_auth_hash(auth_hash)
    user = where(provider: auth_hash.provider, twitter_uid: auth_hash.uid).first_or_create
    user.update(
      first_name: auth_hash.info.name,
      profile_image: auth_hash.info.image,
      token: auth_hash.credentials.token,
      password_digest: auth_hash.credentials.secret
      )
    user
  end

	#########################
	private

    def check_email_duplicates
	    unless self.email.to_s.empty?
	      errors.add(:email, "Email already in the database!") if User.where(email:self.email).any? && 
	                                                                (
	                                                                	self.id.nil? || 
	                                                                  !self.id.nil? && self.email_changed?
	                                                                )
	    end
	  end
end
