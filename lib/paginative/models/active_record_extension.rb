require 'paginative/models/active_record_model_extension'

module Paginative
  module ActiveRecordExtension
    extend ActiveSupport::Concern
    included do
      # Future subclasses will pick up the model extension
      # class << self
      #   def inherited_with_paginative(kls) #:nodoc:
      #     inherited_without_paginative kls
      #     kls.send(:include, Paginative::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
      #   end
      #   alias_method_chain :inherited, :paginative
      # end

      # # Existing subclasses pick up the model extension as well
      # self.descendants.each do |kls|
      #   kls.send(:include, Paginative::ActiveRecordModelExtension) if kls.superclass == ActiveRecord::Base
      # end
    end
  end
end

