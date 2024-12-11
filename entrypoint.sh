#!/bin/bash

set -e

# 初回セットアップ
if [ ! -f /home/environment/bin/rails ]; then
  gem install bundler
  bundle install --without=production
  rails db:migrate
  rails db:seed
fi

# デタッチ時のみサーバー起動
if [[ "$1" == "rails" && "$2" == "server" ]]; then
  exec "$@"
else
  exec bash
fi
