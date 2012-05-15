Redmine Pull Requests
=====================

Github like pull requests for redmine.

### Install

In you redmine dir, execute following commands:

1. ruby script/plugin install git://github.com/xueqiu/redmine_pull_requests.git
1. rake db:migrate_plugins RAILS_ENV=production
1. restart redmine

And then enable the module in your project settings and setup roles permission

### Uninstall

In you redmine dir, execute following commands:

1. rake db:migrate:plugin NAME=redmine_pull_requests VERSION=0 RAILS_ENV=production
1. rm vendor/plugins/redmine_pull_requests
1. restart redmine

### Development

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

0.4
* integrate with activities and email notifications
* sperate new commits as new item (like github)

0.5
* pull request comments
* line comments

