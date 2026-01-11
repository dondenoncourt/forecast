# Cache expiration time for forecast data
# Can be overridden with FORECAST_CACHE_EXPIRATION environment variable
# Default: 30 minutes (1800 seconds)
Rails.application.config.forecast_cache_expiration = ENV.fetch('FORECAST_CACHE_EXPIRATION', 1800).to_i.seconds
