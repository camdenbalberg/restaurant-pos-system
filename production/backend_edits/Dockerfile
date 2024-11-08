# /Dockerfile
# Rails
FROM ruby:3.3.5 AS backend-build

WORKDIR /app/backend

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Install gems
COPY ./panda-web-app-backend/Gemfile* ./
RUN bundle install

# Copy rest of the app code
COPY ./panda-web-app-backend/ ./

# Precompile assets and expose port
RUN bundle exec rake assets:precompile
EXPOSE 3000

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
