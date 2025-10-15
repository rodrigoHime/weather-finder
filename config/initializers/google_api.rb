require "#{Rails.root}/lib/google_api/google_api.rb"

GoogleApi.configure do |config|
  config.api_key = Rails.application.credentials.config[:google_api_key]
end
