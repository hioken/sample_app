#!/usr/bin/env bash
# exit on error
set -o errexit
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate:reset DISABLE_DATABASE_ENVIRONMENT_CHECK=1
