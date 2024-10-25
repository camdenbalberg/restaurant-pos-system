FROM ruby:3.3.5

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

WORKDIR /app

# Install gems
COPY Gemfile* /app/
RUN bundle install

# Copy rest of the app code
COPY . /app

# Precompile assets and expose port
RUN bundle exec rails assets:precompile
EXPOSE 3000

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
