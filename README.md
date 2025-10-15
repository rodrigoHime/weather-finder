# Weather App

An example Rails 7 application that provides:
- Location search using Google Geocoding API.
- Weather forecast lookup using OpenWeatherMap API.
- A simple HTTP API you can call from a browser, curl, or any client.
- Response caching for weather requests (so repeated lookups are fast).

IMPORTANT: In development, caching is disabled by default in Rails. To benefit from the cached weather query, you must explicitly enable caching (see the "Enable cache in development" section below).

## Prerequisites
- Ruby 3.1.7
- Bundler (gem install bundler)

## Getting started
1) Clone and enter the project directory
- git clone <this-repo-url>
- cd weather

2) Install gems
- bundle install

3) Configure credentials (required)
This app expects API keys in Rails encrypted credentials under the "config" namespace:

config:
  open_weather_api_key: YOUR_OPENWEATHER_API_KEY
  google_api_key: YOUR_GOOGLE_API_KEY

Add them using Rails credentials (this will open your editor):
- EDITOR="vim" bin/rails credentials:edit

Notes:
- If you’re running in production you must provide RAILS_MASTER_KEY (value from config/master.key), so Rails can read encrypted credentials.
- The initializers read keys as: Rails.application.credentials.config[:open_weather_api_key] and [:google_api_key].

4) Run the app
- bin/rails server
Open http://localhost:3000

## API endpoints
All routes are namespaced under /api.

1) Location search
- GET /api/locations/search?q=<query>
Example:
- curl "http://localhost:3000/api/locations/search?q=94040"
Response: JSON array of locations with fields like city, state, country, country_code, zip, lat, lon, formatted_address.

2) Weather forecast by zip+country
- GET /api/weather/forecast?zip_code=<ZIP>&country_code=<CC>
Example:
- curl "http://localhost:3000/api/weather/forecast?zip_code=94040&country_code=US"
Response: JSON containing:
- data: Raw response from OpenWeatherMap
- in_cache: boolean indicating if the response came from cache (true on cache hit)
If zip/country is invalid, the response will be HTTP 404 with an error message.

## Enable cache in development 
Weather requests are cached for 30 minutes using Rails.cache. In development, Rails disables caching by default. To enable caching locally, so you can see cache hits (in_cache: true):

- bin/rails dev:cache
This toggles caching and creates tmp/caching-dev.txt, which enables:
- config.action_controller.perform_caching = true
- config.cache_store = :memory_store

You can toggle again to disable caching. Watch the server logs for messages like "Cache hit for key: forecast/<zip>,<country>".

## Running tests
- bundle exec rspec

## Troubleshooting
- Missing credentials: Ensure you’ve set open_weather_api_key and google_api_key under the config: section of Rails credentials.
- 401/403 calling external APIs: Verify your keys are valid and enabled for the correct services.
- No cache hits in development: Run bin/rails dev:cache to enable caching.
