#!/bin/sh

set -e

cd $(dirname $0)/..
bundle install -j4 --quiet --without=production --path vendor/bundle
bin/rake db:create
bin/rake ridgepole:apply
rm -f tmp/pids/server.pid
exec bundle exec gruf
