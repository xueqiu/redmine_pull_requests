desc 'Close any matched pulls with info merged branches'

namespace :redmine do
  task :auto_close_pull => :environment do
    Pull.auto_close
  end
end
