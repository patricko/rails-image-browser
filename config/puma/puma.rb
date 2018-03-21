#!/usr/bin/env puma

directory '/www/apps/rails-image-browser'
rackup "/www/apps/rails-image-browser/config.ru"
environment 'production'

pidfile "/www/apps/rails-image-browser/tmp/pids/puma.pid"
state_path "/www/apps/rails-image-browser/tmp/pids/puma.state"
stdout_redirect '/var/log/puma/rails-image-browser/access.log', '/var/log/puma/rails-image-browser/error.log', true


# threads 0,4

bind 'unix:///www/apps/rails-image-browser/tmp/sockets/puma.sock'

# workers 2
