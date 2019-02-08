class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :desc
      t.belongs_to :company, foreign_key: true

      t.timestamps
    end
    add_index :groups, [:name, :company_id], unique: true
  end
end
