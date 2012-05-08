module RedminePullRequests
  module RepositoryPatch
    def self.included(base)
      base.class_eval do
        has_many :pulls
      end
    end
  end
end