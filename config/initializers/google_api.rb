require "#{Rails.root}/lib/google_api/base.rb"

GoogleApi::Base.configure do |config|
  config.api_key = Rails.application.credentials.config[:google_api_key]
end
