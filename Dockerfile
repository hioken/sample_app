FROM ruby:3.2.5

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libsqlite3-dev \
  imagemagick \
  nodejs \
  yarn

# 作業ディレクトリの設定
WORKDIR /home/environment

# スクリプトをコピー
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

RUN apt-get update && apt-get install -y redis-tools


# ポートを開放
EXPOSE 3000

# デフォルトのエントリーポイント
ENTRYPOINT ["entrypoint.sh"]

# デフォルトのコマンド（デタッチ時はこのコマンドが実行される）
CMD ["rails", "server", "-b", "0.0.0.0"]
