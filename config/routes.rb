Rails.application.routes.draw do
  resources :invitations

  resources :events

  get "users/logout"

  resources :users
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'public#login'

  post "public/authenticate"
  get  "public/create"
  post "public/create"

  # Needed to support FB callbacks, this is where the Facebook authorisation process starts.
  match '/auth/facebook/callback' => 'public#fb_callback', via: [:get]

  # Support Twitter callbacks.
  get '/auth/:provider/callback', to: 'public#create_with_twitter'
end
