module Paginative
  module ModelExtension
    extend ActiveSupport::Concern

    included do
      include Paginative::OrderingHelpers

      mattr_accessor :paginative_fields
      @@paginative_fields = {}

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

        fields = Array.wrap(field).flatten
        values = Array.wrap(value).flatten
        zipped = fields.zip(values)
        fields, values = prune_fields(zipped).transpose

        q = self.all
        if fields.present? && fields.any?
          return raise "Too many" unless fields.length <= 2
          return raise "Something...." unless values.length == fields.length

          mapped_fields = map_fields(fields)
          q = q.order(sanitized_ordering(self.table_name, mapped_fields, order))

          mapped_fields.each_with_index do |field, idx|
            if idx == 0
              value = values[idx]
              operator = sort_operator(idx, mapped_fields.count, order)

              q = q.where("#{field} #{operator} ?", value)
            else
              previous_field = mapped_fields[idx - 1]
              previous_value = values[idx - 1]
              value = values[idx]
              operator = sort_operator(idx, mapped_fields.count, order)

              q = q.where("#{previous_field} != ? OR #{field} #{operator} ?", previous_value, value)
            end
          end
        end

        return q.limit(limit)
      end

      private

      def self.prune_fields(zipped)
        zipped.select{ |f, v| self.paginative_fields.has_key? f.to_sym }.tap do |pruned|
          unless pruned.nil?
            items = zipped.map(&:first) - pruned.map(&:first)
            Rails.logger.warn "Paginative ignored unpermitted field: #{items}"
          end
        end
      end

      def self.map_fields(fields)
        fields.map{ |f| self.paginative_fields[f.to_sym] }
      end

      def self.sort_operator(index, count, direction)
        if direction.try(:downcase) == "desc"
          index < (count - 1) ? '<=' : '<'
        else
          index < (count - 1) ? '>=' : '>'
        end
      end
    end

    module ClassMethods
      def allow_paginative_on(*mappings)
        self.paginative_fields = process_fields(mappings)
      end

      private

      def process_fields(mappings)
        result = {}

        mappings.each do |mapping|
          if mapping.is_a?(Hash)
            result.merge!(mapping)
          else
            result[mapping] = self_map(mapping)
          end
        end

        result
      end

      def self_map(field)
        "#{self.table_name}.#{field}"
      end
    end
  end
end
