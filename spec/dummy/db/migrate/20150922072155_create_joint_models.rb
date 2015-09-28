class CreateJointModels < ActiveRecord::Migration
  def change
    create_table :joint_models do |t|
      t.string :name
      t.references :test_model, index: true

      t.timestamps null: false
    end
  end
end
