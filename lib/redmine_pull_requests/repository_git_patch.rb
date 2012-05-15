module RedminePullRequests
  module RepositoryGitPatch
    
    def self.included(base)
      #base.extend(ClassMethods)
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
      
      def diff_with_three_dot(path, identifier_from, identifier_to=nil)
        path ||= ''
        cmd_args = []
        if identifier_to
          cmd_args << "diff" << "--no-color" <<  identifier_to << "..." << identifier_from
        else
          cmd_args << "show" << "--no-color" << identifier_from
        end
        cmd_args << "--" <<  scm_iconv(@path_encoding, 'UTF-8', path) unless path.empty?
        diff = []
        git_cmd(cmd_args) do |io|
          io.each_line do |line|
            diff << line
          end
        end
        diff
      rescue ScmCommandAborted
        nil
      end      
    end
  
  end
end