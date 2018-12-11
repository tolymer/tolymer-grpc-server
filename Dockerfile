FROM ruby:2.5.3

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential libpq-dev postgresql-client && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock /app/
RUN bundle install -j4 --without=production --path vendor/bundle

CMD ["bin/start_dev"]
