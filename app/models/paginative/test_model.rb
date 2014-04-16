module Paginative
  class TestModel < ActiveRecord::Base
    include Paginative::ModelExtension

    reverse_geocoded_by :latitude, :longitude
    after_validation :reverse_geocode          # auto-fetch coordinates
  end
end
