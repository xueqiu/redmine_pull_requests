Redmine Pull Requests
=====================

Github like pull requests plugin for redmine.

### Install

In you redmine dir, execute following commands:

1. ruby script/plugin install git://github.com/xueqiu/redmine_pull_requests.git
1. rake db:migrate_plugins RAILS_ENV=production
1. install git repository post-receive hook
```
  (rake -f /data/deploy/redmine-1.4.1/Rakefile redmine:fetch_changesets && \ 
   rake -f /data/deploy/redmine-1.4.1/Rakefile redmine:auto_close_pull) > /dev/null 2>&1 &
```
1. restart redmine

And then enable the module in your project settings and setup roles permission

### Uninstall

In you redmine dir, execute following commands:

1. rake db:migrate:plugin NAME=redmine_pull_requests VERSION=0 RAILS_ENV=production
1. rm -rf vendor/plugins/redmine_pull_requests
1. remove git repository post-receive hook
1. restart redmine

### Development (plugin for redmine)

Please refer to http://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial

### TODO

0.3
* Don't creat new one when there is PR with same base/head branches and it's not closed
* Send pull request to specified users with notifictaions
* Check pull request's status before merge or close
  * must be viewed by at lease one other user
  * can't be merged or closed by the sender himself

0.4
* Line comments