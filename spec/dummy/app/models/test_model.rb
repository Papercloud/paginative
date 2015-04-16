class TestModel < ActiveRecord::Base
  include Paginative::ModelExtension

  reverse_geocoded_by :latitude, :longitude
end
