module Paginative
  class Hooks
    def self.init
      ActiveSupport.on_load(:active_record) do
        require 'paginative/models/active_record_extension'
        ::ActiveRecord::Base.send :include, Paginative::ActiveRecordExtension
      end
    end
  end
end
