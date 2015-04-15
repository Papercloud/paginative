module Paginative
  module OrderingHelpers
    extend ActiveSupport::Concern

    def sanitized_ordering(table_name, field, order)
      if field.is_a? Array
        return raise "Wrong number of sorting fields. Expected 2, got #{field.length}. If you want to sort by a singular field please pass field argument as a string rather than an array." unless field.length == 2
        "'#{table_name}.#{sanitize_column(field[0])} || #{table_name}.#{sanitize_column(field[1])}' #{sanitize_column_direction(order)}"
      else
        "#{table_name}.#{sanitize_column(field)} #{sanitize_column_direction(order)}"
      end
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
