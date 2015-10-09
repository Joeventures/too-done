class CreateTasks < ActiveRecord::Migration
  def up
    create_table :tasks do |t|
      t.string :name, null: false
      t.integer :todo_list_id, null: false
      t.date :due_date
      t.boolean :completed
    end
  end

  def down
    drop_table :tasks
  end
end
