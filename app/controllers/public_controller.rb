# Everything that should be accessible to users who aren't logged in.

class PublicController < ApplicationController

	def login
	end

  def create
    if request.get?
      @user = User.new
    else
      @user = User.new user_params

      if @user.save
        flash[:notice] = "Account created successfully."
        session[:user_id] = @user.id
        redirect_to action:'index', controller:'events'
      end
    end
  end

	# Called by the login form. Tries to find the user by email and authenticate them;
	# if the authentication works, redirects to someplace private in the UsersController
  def authenticate
  	user = User.find_by(email:params[:email]).try(:authenticate, params[:password])

  	if user
  		# If the user is authenticated, we save the user_id in their session.
  		# We use this, later, to load the logged_in_user in a controller's "before" filter.
  		logger.info "USER #{user.id} AUTHENTICATED"
  		session[:user_id] = user.id

  		# If the user came directly to a private page, the filter will have set session[:requested_fullpath]
  		# and redirected them away to this login page. So, once they are authenticated, we can redirect them
  		# back to where they initially wanted to go, then clear that value. 
  		if session[:requested_fullpath]
  			logger.info "SENDING USER TO INTENDED URI: #{session[:requested_fullpath]}"
  			redirect_to session[:requested_fullpath]
  			session[:requested_fullpath] = nil
  		else
  			logger.info "SENDING USER SOMEPLACE NICE"
	  		redirect_to controller:'events', action:'index'
	  		
	  		# TODO: Implement a case statement here that will redirect users
	  		# to different places based on whether they are regular users, event organisers, the website superadmin, etc.
	  		# based on user.roleid
	  	end
  	else
  		# If authentication fails, we set a flash message and redirect to ourselves.
  		logger.info "AUTHENTICATION FAILURE"
  		flash[:error] = "Incorrect username or password!"
  		redirect_to action:'login'
  	end
  end

  # The Facebook callback method.
  def fb_callback
    # First, get a hash with everything Facebook tells us about the user.
    fb_hash=request.env['omniauth.auth']

    # We'll need the following two things so let's save them into local variables.
    fb_uid   = fb_hash['uid']
    fb_email = fb_hash['info']['email']

    # If a user is already logged in, we only need to update the existing User record.
    if logged_in_user = User.where(id:session[:user_id]).first
      # This happens in the "edit my profile" context, where the logged in user simply associates
      # their Chameleon account to their Facebook account (meaning, their facebook_uid gets set in the
      # `users` table).
      logger.info "------ edit profile context -------"
      logged_in_user.update_attribute :facebook_uid, fb_uid
      redirect_to action:'index', controller:'events' # TODO: for now, go to Events#index, but should go to the My Profile page once we have that.

    else # No user logged in, so let's see if there's already a user with the received UID or email.

      user_with_uid   = User.where(facebook_uid:fb_uid).first
      user_with_email = User.where(email:fb_email).first

      if user_with_uid.nil? && user_with_email.nil?
        # No logged in user, and no user with that email or UID exists in our database, so this is a SIGNUP operation.
        logger.info "\n Creating new user from fb hash #{fb_hash}"
        new_user = User.create_from_facebook(fb_hash)

        if new_user.id.nil?
          # User was not saved, there was a problem.
          logger.info "\n COULD NOT CREATE USER VIA FACEBOOK: #{new_user.errors.inspect}"
          flash['error'] = "There was a problem creating an account for you."
          redirect_to '/'
          return
        end
      end

      logger.info "user with email exists" if user_with_email
      logger.info "user with fbuid exists" if user_with_uid
      logger.info "this is a new user" if new_user

      # By now, the user is either new, or we're logging in a user who has the same UID as the one from Facebook,
      # or we're logging in someone with the same email.
      session[:user_id] = user_with_uid.try(:id) || # If there was already a user with that UID, then this is a LOGIN operation.
                          (user_with_email.try(:update_attribute, :facebook_uid, fb_uid) && user_with_email.try(:id)) || # If there was already a user with that email, then this is also a LOGIN operation, but we also save the UID.
                          new_user.try(:id) # If this was a SIGNUP operation then new_user will have an id.

      # The only alternative is if user creation failed; then new_user.try(:id) will return nil, session[:user_id] will stay nil
      # and the authentication filter in EventsController will redirect back to login.

      # Either way, it's time to go someplace.
      redirect_to action:'index', controller:'events'

    end
  end



  #######################
  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :terms_of_service)
    end
end
