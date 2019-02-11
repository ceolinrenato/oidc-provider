# specify the ruby version
FROM ruby:2.6.1

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs postgresql-client

RUN mkdir /oidcprovider

WORKDIR /oidcprovider

COPY Gemfile /oidcprovider/Gemfile
COPY Gemfile.lock /oidcprovider/Gemfile.lock

RUN bundle install

COPY . /oidcprovider

