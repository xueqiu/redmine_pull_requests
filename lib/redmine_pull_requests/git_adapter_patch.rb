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
      def diff_with_three_dot(path, identifier_from, identifier_to=nil)
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
            
    end
  end
end