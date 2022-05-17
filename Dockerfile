FROM ruby:3.0.4

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential nodejs libpq-dev git


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
