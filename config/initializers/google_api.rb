require "#{Rails.root}/lib/google_api/api.rb"

GoogleApi.configure do |config|
  config.api_key = Rails.application.credentials.config[:google_api_key]
end
