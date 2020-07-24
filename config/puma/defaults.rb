#!/usr/bin/env puma

rails_root = File.expand_path("../../..", __FILE__)

directory rails_root
rackup "#{rails_root}/config.ru"

tag ""

pidfile "#{rails_root}/tmp/pids/puma.pid"
state_path "#{rails_root}/tmp/pids/puma.state"
stdout_redirect "#{rails_root}/log/puma_access.log", "#{rails_root}/log/puma_error.log", true

max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

environment ENV.fetch("RAILS_ENV") { "development" }
plugin :tmp_restart

preload_app!

on_restart do
  puts "Refreshing Gemfile"
  ENV["BUNDLE_GEMFILE"] = ""
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
