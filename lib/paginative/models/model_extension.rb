module Paginative
  module ModelExtension
    extend ActiveSupport::Concern

    included do
      include Paginative::OrderingHelpers

      def self.by_distance_from(latitude, longitude, distance=0, limit=25)
        return [] unless latitude.present? && longitude.present?
        distance_sql = send(:distance_sql, latitude.to_f, longitude.to_f, {:units => :km, select_bearing: false})

        self.where("#{distance_sql} >  ?", distance).offset(0).limit(limit)
      end

      def self.with_name_from(name="", limit=25, order="asc")
        return self.order("name DESC").where("lower(name) < ?", name.downcase).offset(0).limit(limit) if order == "desc"
        self.order(name: :asc).where("lower(#{self.table_name}.name) > ?", name.downcase).offset(0).limit(limit)
      end

      def self.with_id_from(id=0, limit=25)
        self.order(id: :asc).where("id > ?", id).limit(limit)
      end

      def self.with_field_from(field="", value="", limit=25, order="asc")
        order ||= "asc"
        if field.is_a? Array
          return raise "Wrong number of values. Expected 2, got #{value.try(:length)}. You must pass a value for each field that you are sorting by" unless value.is_a?(Array) && value.length == 2
            # You can now pass in an array of 'field' params so that you can have a secondary sort order.
            # This is important if your primary sort field could have duplicate values
            primary_sort_field = field[0]
            primary_value = value[0]
            secondary_sort_field = field[1]
            secondary_value = value[1]
            # This allows us to pass in 2 different sort columns and still paginate correctly.
            return self.order(sanitized_ordering(self.table_name, field, order)).where("#{self.table_name}.#{primary_sort_field} <= ? AND (#{self.table_name}.#{primary_sort_field} != ? OR #{self.table_name}.#{secondary_sort_field} < ?)", primary_value, primary_value, secondary_value) if order.try(:downcase) == "desc"

            self.order(sanitized_ordering(self.table_name, field, order)).where("#{self.table_name}.#{primary_sort_field} >= ? AND (#{self.table_name}.#{primary_sort_field} != ? OR #{self.table_name}.#{secondary_sort_field} > ?)", primary_value, primary_value, secondary_value)
          else
            value = value.to_i if self.column_for_attribute(field).type == :integer
            return self.order(sanitized_ordering(self.table_name, field, order)).where("#{self.table_name}.#{field} < ?", value).limit(limit) if order.try(:downcase) == "desc"
            self.order(sanitized_ordering(self.table_name, field, order)).where("#{self.table_name}.#{field} > ?", value).limit(limit)
          end
        end
      end
    end
  end
