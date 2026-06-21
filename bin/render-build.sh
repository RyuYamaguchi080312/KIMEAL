#!/usr/bin/env bash

set -o errexit

bundle install
bin/rails assets:precompile
bin/rails assets:clean

# Free Render web services cannot use pre-deploy commands, so migrations run here.
bin/rails db:migrate
