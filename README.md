# README

This a sample rails application. It displays the weather based on user entry of address. 

* Ruby version
3.2.9

* Rails version
7.1.6

The user enters a full address and the current conditions are displayed
![UI invokes Forecast API](/public/forecast-UI-API-called.png)

The user requests an address with the same zip code within a 30 minute window, and the Rails' cached data is used and the forecast API is not invoked

![Backend used cached Forecast data](/public/forecast-UI-used-cache.png)

Code Coverage was implemented, here's a sample report:

![Code coverage](/public/forecast-code-coverage.png)

* Database creation

The application was configured for PostgreSQL but it does not use any database data.
The "data" for the application is JSON returned from the Open-Meteo API. 

The JSON data is cached via the integrated [Rails cache](https://guides.rubyonrails.org/v2.3.9/caching_with_rails.html#:~:text=ActionController::Base.,updated_at%20timestamp%20(if%20available).)

* How to run the test suite

`rspec spec`

* Services (job queues, cache servers, search engines, etc.)

The `ForcastService` class uses the 
[Open-Meteo](https://open-meteo.com/en/docs?hourly=#api_documentation)
Weather Forecast API. It is free for non-commerical use.
The API requires a longitude and latitude which are retrieved from the address via [geocoding](https://open-meteo.com/en/docs/geocoding-api)

* Documentation

[RDoc Documentation](doc/index.html) - View the generated API documentation as HTML.
Here is a sample page: 
![sample page](/public/RDoc-sample.png)
