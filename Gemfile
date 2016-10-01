# source 'https://rubygems.org'
source 'https://gems.ruby-china.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 3.3'
# Ruby wrapper for hiredis, Read more: https://github.com/redis/hiredis-rb
gem "hiredis", "~> 0.6.0"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

############################################################################################################
# Simple Rails app configuration
# Read more: https://github.com/laserlemon/figaro
gem "figaro"
# ruby-netcdf fork allowing install through Rubygems
# Read more: https://github.com/gentooboontoo/gentooboontoo-ruby-netcdf
gem 'ruby-netcdf', '~> 0.7.1.1'
# A generic swappable back-end for JSON handling. http://rdoc.info/projects/intridea/multi_json
# Read more: https://github.com/intridea/multi_json
gem 'multi_json'
############################################################################################################

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
