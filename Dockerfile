FROM ruby:2.7.1-alpine

# Set Rails environment to production
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# Setup workdir
ENV APP_HOME /app
WORKDIR $APP_HOME

# Install libraries
RUN gem install bundler:2.1.4 \
    && apk add --update build-base postgresql-dev tzdata # nodejs

# Install gems
COPY Gemfile Gemfile.lock $APP_HOME/
RUN bundle config set deployment 'true' \
    && bundle config set path '/gems' \
    && bundle install

# Get the rest of the app
COPY . $APP_HOME

# Precompile the assets
RUN bundle exec rake assets:precompile

# Start the app
CMD bundle exec rails s
