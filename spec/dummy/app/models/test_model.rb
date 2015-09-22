class TestModel < ActiveRecord::Base
  include Paginative::ModelExtension

  reverse_geocoded_by :latitude, :longitude

  # Associations
  has_many :joint_models

  class << self
    def joint
      joins(:joint_models).select('test_models.*, joint_models.created_at')
        .order('joint_models.created_at DESC')
    end
  end
end
