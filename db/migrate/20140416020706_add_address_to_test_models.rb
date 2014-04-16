class AddAddressToTestModels < ActiveRecord::Migration
  def change
    add_column :paginative_test_models, :address, :string
  end
end
