Redmine Pull Requests
=====================

Github like pull requests plugin for redmine.

### Install

In you redmine dir, execute following commands:

1. ruby script/plugin install git://github.com/xueqiu/redmine_pull_requests.git
1. rake db:migrate_plugins RAILS_ENV=production
1. install git repository post-receive hook
```
  (rake -f /data/deploy/redmine-1.4.1/Rakefile redmine:fetch_changesets ; \ 
   rake -f /data/deploy/redmine-1.4.1/Rakefile redmine:auto_close_pull) > /dev/null 2>&1 &
```
1. restart redmine

And then enable the module in your project settings and setup roles permission

### Uninstall

In you redmine dir, execute following commands:

1. rake db:migrate:plugin NAME=redmine_pull_requests VERSION=0 RAILS_ENV=production
1. rm vendor/plugins/redmine_pull_requests
1. remove git repository post-receive hook
1. restart redmine

### Development (plugin for redmine)

Please refer to http://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial

### TODO

0.1
* basic CRUD for pull requests
* pull request for any two branches
* versions and files diff
* tracing pull request status

0.2
* auto merge
* git hook for close

0.3
* redmine hook for branch to pull request
* verify if there have pull request conflict
* integrate with activities and email notifications

0.4
* pull request comments
* line comments

