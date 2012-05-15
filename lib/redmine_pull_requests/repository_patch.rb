module RedminePullRequests
  module RepositoryPatch
    def self.included(base)
      base.class_eval do
        has_many :pulls
      end
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
    end
    
    def diff_with_three_dot(path, rev, rev_to)
      scm.diff_with_three_dot(path, rev, rev_to)
    end 
            
  end
end