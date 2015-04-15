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
            return raise "Wrong number of sorting fields. Expected 2, got #{field.length}. If you want to sort by a singular field please pass field argument as a string rather than an array." unless field.length == 2
            # You can now pass in an array of 'field' params so that you can have a secondary sort order.
            # This is important if your primary sort field could have duplicate values
            primary_sort_field = field[0]
            secondary_sort_field = field[1]
            return self.order(sanitized_ordering(self.table_name, primary_sort_field, order), sanitized_ordering(self.table_name, secondary_sort_field, order)).where("#{secondary_sort_field} < ?", value).limit(limit) if order.downcase == "desc"
            self.order(sanitized_ordering(self.table_name, primary_sort_field, order), sanitized_ordering(self.table_name, secondary_sort_field, order)).where("#{secondary_sort_field} > ?", value).limit(limit)
          else
            return self.order(sanitized_ordering(self.table_name, field, order)).where("#{field} < ?", value).limit(limit) if order.downcase == "desc"
            self.order(sanitized_ordering(self.table_name, field, order)).where("#{field} > ?", value).limit(limit)
          end
        end
    end
  end
end
