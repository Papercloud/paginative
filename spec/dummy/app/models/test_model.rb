class TestModel < ActiveRecord::Base
  include Paginative::ActiveRecordModelExtension

  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode          # auto-fetch coordinates
end
