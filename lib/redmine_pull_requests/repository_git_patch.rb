require 'redmine/scm/adapters/abstract_adapter'
require 'redmine/scm/adapters/git_adapter'

module RedminePullRequests
  module RepositoryGitPatch
    
    def self.included(base)
#      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
    end    
    
    module InstanceMethods
      def revisions(path, identifier_from, identifier_to, options={})
        revisions = scm.revisions(path, identifier_from, identifier_to, options)
        return [] if revisions.nil? || revisions.empty?

        changesets.find(
          :all,
          :conditions => [
            "scmid IN (?)",
            revisions.map!{|c| c.scmid}
          ],
          :order => 'committed_on DESC'
        )
      end

      def branch_ancestor(base_branch, head_branch)
        repo_path = self.url
        cmd = "bash -c 'diff -u <(git --git-dir #{repo_path} rev-list #{head_branch}) <(git --git-dir #{repo_path} rev-list #{base_branch}) | tail -3|head -1'"
        fhi = IO.popen(cmd)
        while (line = fhi.gets)
          revision = line
        end
        revision ? revision.gsub("\n", "").strip : '+-'
      end
    end
  end
end