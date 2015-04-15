module Paginative
  module OrderingHelpers
    extend ActiveSupport::Concern

    def sanitized_ordering(table_name, field, order)
      "#{table_name}.#{sanitize_column(field)} #{sanitize_column_direction(order)}"
    end

    private
    def sanitize_column(column)
      resource.column_names.include?(column) ? column : "created_at"
    end

    def sanitize_column_direction(direction)
      direction = direction.upcase
      ['DESC', 'ASC'].include?(direction) ? direction : "DESC"
    end

    def resource
      controller_name.camelize.singularize.safe_constantize
    end
  end
end
