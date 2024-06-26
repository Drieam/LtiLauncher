FROM ruby:3.2.3-alpine

# Set Rails environment to production
ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# Setup workdir
ENV APP_HOME /app
WORKDIR $APP_HOME

# Install libraries
RUN gem install bundler:2.2.33 \
    && apk add --update build-base postgresql-dev tzdata

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
