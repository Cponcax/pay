source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.1'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'

gem 'figaro'

gem 'devise'
gem 'doorkeeper'
gem 'carrierwave'
gem 'carrierwave-base64'

gem 'active_model_serializers'
gem 'rest-client'

gem 'sidekiq'
gem 'faraday'
gem 'jwt'
gem 'rack-cors', :require => 'rack/cors'
gem 'kaminari'

gem 'redis'

gem 'arel'
gem 'ransack'
gem 'money-rails'
gem 'fog'
gem "fog-google"
gem "google-api-client"
gem "mime-types"

gem 'skylight'
gem 'virtus'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'pry-rails'
  gem 'pry'
  gem 'mailcatcher'

end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
