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

  #######################
  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :terms_of_service)
    end
end
