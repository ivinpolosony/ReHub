class CreateDatasources < ActiveRecord::Migration
  def change
    create_table :datasources do |t|
      t.string :datasource_type
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
