module Paginative
  module ActiveRecordModelExtension
    extend ActiveSupport::Concern

    included do
      # Fetch all the deleted ids from the backend, and return them as an array
      #   Model.delted_ids = []
      eval <<-RUBY
        def self.with_distance_from(distance, limit)

        end

        def self.with_name_from(name="", limit=25)
            self.where("name >= ?", name).offset(0).limit(limit)
        end
      RUBY
    end
  end
end



# all_wineries = @wineries
# subset = nil
# if params[:start] == "1"
#  subset = all_wineries.limit(limit_value)
# elsif params[:from]
#   if params[:near]
#     distance_sql = Winery.send(:distance_sql, params[:near][:latitude], params[:near][:longitude], {:units => :km, select_bearing: false})
#     subset = all_wineries.where("#{distance_sql} >= #{params[:from][:distance]}").offset(0).limit(limit_value)
#   else
#     subset = all_wineries.where('LOWER(wineries.name) >= ?', params[:from][:name].downcase).offset(0).limit(limit_value)
#   end
# end
