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
        if identifier_to
          cmd_args << "diff" << "--no-color" <<  "#{identifier_to}...#{identifier_from}"
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
      end
      
            
    end
  end
end