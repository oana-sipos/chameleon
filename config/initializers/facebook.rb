f = YAML.load_file "#{Rails::root}/config/facebook.yml" rescue {}

fb_key    = f['app_id'] || 'no_facebook_yml'
fb_secret = f['secret'] || 'no_facebook_yml'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, fb_key, fb_secret
end
