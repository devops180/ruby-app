FROM ruby:2.6

RUN apt-get update -qq \
    && apt-get -y install apt-transport-https apt-utils curl \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update -qq \
    && apt-get install -y build-essential libpq-dev nodejs yarn \
      # remove useless files from the current layer
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/lib/apt/lists.d/* \
    && apt-get autoremove \
    && apt-get clean \
    && apt-get autoclean
    
ENV RAILS_ENV production
COPY gems /app/gems
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock

RUN cd /app && bundle install --without test development

WORKDIR /app
COPY . /app
COPY config/database.yml.example config/database.yml

RUN SECRET_KEY_BASE=foobar STRIPE_SECRET_KEY=foobar RAILS_GROUPS=assets \
    bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
