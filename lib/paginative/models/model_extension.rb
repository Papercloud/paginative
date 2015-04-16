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
        if field.is_a? Array
          return raise "Wrong number of values. Expected 2, got #{value.try(:length)}. You must pass a value for each field that you are sorting by" unless value.is_a?(Array) && value.length == 2
            # You can now pass in an array of 'field' params so that you can have a secondary sort order.
            # This is important if your primary sort field could have duplicate values
            primary_sort_field = field[0]
            primary_value = value[0]
            secondary_sort_field = field[1]
            secondary_value = value[1]
            # Postgres sorts strings differently to Rails. We use the Postgres string concat and sort so that there is no confusion here.
            # We need to treat the 2 columns as one string to accurately paginate from a certain point when 2 columns are passed into the argument

            # If we are dealing with integers we need to do some black maging. Concat them as strings, and then return them to their integer value.
            if primary_value.is_a?(Integer) && secondary_value.is_a?(Integer)
              return self.order(sanitized_integer_ordering(self.table_name, field, order)).offset("row_number() FROM #{primary_sort_field} WHERE #{secondary_sort_field} = #{secondary_value} ORDER BY #{primary_sort_field} #{order.upcase}")

            elsif primary_value.is_a?(String) && secondary_value.is_a?(String)
              return self.order(sanitized_string_ordering(self.table_name, field, order)).where("#{primary_sort_field} || #{secondary_sort_field} < ?", "#{primary_value}#{secondary_value}").limit(limit) if order.try(:downcase) == "desc"
              self.order(sanitized_string_ordering(self.table_name, field, order)).where("#{primary_sort_field} || #{secondary_sort_field} > ?", "#{primary_value}#{secondary_value}").limit(limit)
            else
              return raise "Paginative can only handle either 2 string values, or two integer values at this stage. Sorry"
            end
          else
            return self.order(sanitized_string_ordering(self.table_name, field, order)).where("#{field} < ?", value).limit(limit) if order.try(:downcase) == "desc"
            self.order(sanitized_string_ordering(self.table_name, field, order)).where("#{field} > ?", value).limit(limit)
          end
        end
      end
    end
  end
