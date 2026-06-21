# Rails Initial Template

KIMEALのRails初期設定で使うテンプレートです。既存の学習プロジェクトの構成を参考にしつつ、今回はPostgreSQL前提で整理しています。

## 1. Railsアプリ作成

```bash
rails new . -d postgresql
```

既存のREADMEやdocを残したい場合は、生成前に退避するか、上書き確認時に内容を確認します。

## 2. 想定技術

- Ruby 3.4.8
- Rails 8.0.2
- PostgreSQL
- Hotwire
- Devise
- Pundit
- Faraday
- Ransack
- RSpec
- RuboCop

## 3. 追加Gem候補

```ruby
gem "devise"
gem "pundit"
gem "faraday"
gem "ransack"

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rubocop"
  gem "rubocop-rails"
  gem "pry-byebug"
end
```

## 4. Dockerfile.dev

開発環境用のDockerイメージを作るため、プロジェクト直下に `Dockerfile.dev` を作成します。

```dockerfile
FROM ruby:3.4.8

ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

RUN apt-get update -qq \
&& apt-get install -y ca-certificates curl gnupg \
&& mkdir -p /etc/apt/keyrings \
&& curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
&& curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /etc/apt/keyrings/yarn.gpg \
&& NODE_MAJOR=20 \
&& echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
&& echo "deb [signed-by=/etc/apt/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs yarn vim

RUN mkdir /kimeal
WORKDIR /kimeal

RUN gem install bundler

COPY . /kimeal
```

## 5. compose.yml

PostgreSQLコンテナとRailsアプリコンテナを連携させるため、プロジェクト直下に `compose.yml` を作成します。

```yaml
services:
  db:
    image: postgres
    restart: always
    environment:
      TZ: Asia/Tokyo
      POSTGRES_PASSWORD: password
    volumes:
      - postgresql_data:/var/lib/postgresql
    ports:
      - 5432:5432
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -d kimeal_development -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    command: bash -c "bundle install && bundle exec rails db:prepare && rm -f tmp/pids/server.pid && ./bin/dev -b 0.0.0.0"
    tty: true
    stdin_open: true
    volumes:
      - .:/kimeal
      - bundle_data:/usr/local/bundle:cached
      - node_modules:/kimeal/node_modules
    environment:
      TZ: Asia/Tokyo
    ports:
      - "3000:3000"
    depends_on:
      db:
        condition: service_healthy

volumes:
  bundle_data:
  postgresql_data:
  node_modules:
```

## 6. config/database.yml

Docker Compose上のPostgreSQLへ接続するため、`config/database.yml` の共通設定に `host`、`username`、`password` を追加します。

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: db
  username: postgres
  password: password

development:
  <<: *default
  database: kimeal_development

test:
  <<: *default
  database: kimeal_test
```

`host: db` は `compose.yml` の `db` サービス名に合わせています。

## 7. トップページ仮作成

```bash
bin/rails generate controller top index
```

`config/routes.rb`

```ruby
Rails.application.routes.draw do
  root "top#index"
end
```

## 8. 初期確認

```bash
bin/rails db:create
bin/rails server
```

ブラウザで `http://localhost:3000` を開き、トップページが表示されればIssue #4の完了条件を満たします。

Dockerを使う場合:

```bash
docker compose up
```

## 9. Issueベース開発ルール

- 作業はIssue単位で開始する
- ブランチ名にはIssue番号を入れる
- PR本文に `Closes #Issue番号` を書く
- 1つのPRで扱う目的を広げすぎない

ブランチ例:

```bash
git switch -c feature/4-rails-initial-setup
```
