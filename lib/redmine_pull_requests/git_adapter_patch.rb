require 'redmine/scm/adapters/abstract_adapter'
require 'redmine/scm/adapters/git_adapter'

module RedminePullRequests
  module GitAdapterPatch
    
    def self.included(base)
#      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
    end    
    
    module InstanceMethods
      
      def diff_with_merge_base(path, identifier_from, identifier_to=nil)
        path ||= ''
        cmd_args = []
        cmd_args << "diff" << "--no-color" <<  "#{identifier_to}...#{identifier_from}"
        cmd_args << "--" <<  scm_iconv(@path_encoding, 'UTF-8', path) unless path.empty?
        diff = []
        git_cmd(cmd_args) do |io|
          io.each_line do |line|
            diff << line
          end
        end
        diff
      rescue Redmine::Scm::Adapters::AbstractAdapter::ScmCommandAborted
        nil
      end

      def diff_files_with_merge_base(path, identifier_from, identifier_to=nil)
        path ||= ''
        cmd_args = []
        cmd_args << "diff" << "--no-color" << "--name-only" <<  "#{identifier_to}...#{identifier_from}"
        cmd_args << "--" <<  scm_iconv(@path_encoding, 'UTF-8', path) unless path.empty?
        files = []
        git_cmd(cmd_args) do |io|
          io.each_line do |line|
            files << line.gsub(/\n/, '')
          end
        end
        files
      rescue Redmine::Scm::Adapters::AbstractAdapter::ScmCommandAborted
        nil
      end

      def merge_base(identifier_from, identifier_to)
        cmd_args = []
        cmd_args << "merge-base" <<  "#{identifier_from}" << "#{identifier_to}"
        revision = nil
        git_cmd(cmd_args) do |io|
          io.each_line do |line|
            revision = line.gsub(/\n/, '')
          end
        end
        revision
      rescue Redmine::Scm::Adapters::AbstractAdapter::ScmCommandAborted
        nil
      end 
      
      def merge_conflict?(identifier_from, identifier_to)
        base = merge_base(identifier_from, identifier_to)
        
        conflict = false
        if base
          cmd_args = []
          cmd_args << "merge-tree" << "#{base}" << "#{identifier_from}" << "#{identifier_to}"
        
          git_cmd(cmd_args) do |io|
            io.each_line do |line|
              if line.include?("<<<<")
                conflict = true
                break
              end
            end
          end
        end
        conflict
      rescue Redmine::Scm::Adapters::AbstractAdapter::ScmCommandAborted
        nil
      end

      def merge(repo_name, identifier_from, identifier_to)
        #script = "#{RAILS_ROOT}/vendor/plugins/redmine_pull_requests/script/git-auto-merge"
        return if merge_conflict?(identifier_from, identifier_to) 
        script = "#{File.dirname(__FILE__)}/../../script/git-auto-merge"
        repo_path = root_url || url

        result = []
        ret = shellout("#{script} #{repo_path} #{identifier_from} #{identifier_to} #{repo_name}") do |io|        
          io.each_line do |line|
            result << line
          end
        end
        result        
      rescue Redmine::Scm::Adapters::AbstractAdapter::ScmCommandAborted
        nil
      end

      def merge_directly(identifier_from, identifier_to)
        cmd_args = []
        cmd_args << "merge" << "--no-ff" <<  "#{identifier_from}" << "#{identifier_to}"
        result = []
        git_cmd(cmd_args) do |io|
          io.each_line do |line|
            result << line
          end
        end
        result
      rescue Redmine::Scm::Adapters::AbstractAdapter::ScmCommandAborted
        nil
      end
                  
    end
  end

end