desc 'Close any matched pulls with info merged branches'

namespace :redmine do
  task :auto_close_pull => :environment do
    Pull.auto_close
  end

  desc "Check if branch could be merge, execute with parameters: base=develop head=add-check-merge"
  task :check_merge => :environment do
	base_branch = "#{ENV['base']}"
  	head_branch = "#{ENV['head']}"
  	puts Pull.could_be_merge?(base_branch, head_branch)
  end
end
