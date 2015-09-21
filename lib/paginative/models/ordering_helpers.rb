module Paginative
  module OrderingHelpers
    extend ActiveSupport::Concern

    included do
      def self.sanitized_ordering(table_name, fields, order)
        fields.map do |field|
          "#{field} #{sanitize_column_direction(order)}"
        end.join(', ')
      end

      private

      def self.sanitize_column_direction(direction)
        direction = direction.upcase
        ['DESC', 'ASC'].include?(direction) ? direction : "ASC"
      end
    end
  end
end
