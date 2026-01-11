# Cache expiration time for forecast data
# Can be overridden with FORECAST_CACHE_EXPIRATION environment variable
# Default: 1 minute (60 seconds)
Rails.application.config.forecast_cache_expiration = ENV.fetch('FORECAST_CACHE_EXPIRATION', 60).to_i.seconds
