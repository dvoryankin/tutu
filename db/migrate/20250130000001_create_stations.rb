class CreateStations < ActiveRecord::Migration[7.0]
  def change
    create_table :stations do |t|
      t.string :title, null: false
      t.string :type, null: false
      t.string :city
      t.string :code

      t.timestamps
    end

    add_index :stations, :type
    add_index :stations, :city
    add_index :stations, :code, unique: true, where: "code IS NOT NULL"
  end
end
