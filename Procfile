release: bundle exec rails db:migrate
web: bundle exec puma -C config/puma/$RAILS_ENV.rb
worker: bundle exec rake jobs:work
