class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Use this method as a before_filter in all controllers that should only
  # be accessible to logged in users.
  def authenticate_and_load_user
   	@logged_in_user = User.where(id:session[:user_id]).first

   	if @logged_in_user.nil?
   		flash[:error] = 'You must be authenticated to visit this page'
   		# Save the user's intended destination in the session, so we can
   		# take them there once they've logged in.
   		session[:requested_fullpath] = request.fullpath
   		redirect_to controller:'public', action:'login'
   		false # return false to prevent execution of controller methods
   	else
   		true
   	end
  end
end
