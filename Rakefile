# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

namespace :sidekiq do
  task :start do
    sh "bundle exec sidekiq  -e #{env} -C ./config/sidekiq.yml &"
  end

  task :stop do
    sh 'bundle exec sidekiqctl stop tmp/pids/sidekiq.pid 0'
  end
end
