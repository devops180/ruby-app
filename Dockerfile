FROM ruby:3.0-alpine

RUN apt-get update && apt-get install -y \
  curl \
  git \
  build-essential \
  libpq-dev &&\
  curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -y nodejs yarn


ENV RAILS_ENV=production RACK_ENV=production SECRET_KEY_BASE=xpto APP_HOME=/app/

ADD Gemfile* $APP_HOME
RUN bundle config set without 'test development'

RUN cd $APP_HOME && gem install bundler && bundle install

COPY package.json yarn.lock $APP_HOME
RUN cd $APP_HOME && yarn install

ADD ./ $APP_HOME
WORKDIR $APP_HOME

RUN cp config/database.yml.example config/database.yml

RUN RAILS_GROUPS=assets RAILE_ENV=production bundle exec rake assets:precompile
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
