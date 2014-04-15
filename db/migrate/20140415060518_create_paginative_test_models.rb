class CreatePaginativeTestModels < ActiveRecord::Migration
  def change
    create_table :paginative_test_models do |t|
      t.string :name
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
