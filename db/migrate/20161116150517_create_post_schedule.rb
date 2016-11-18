class CreatePostSchedule < ActiveRecord::Migration
  def change
    create_table :post_schedules do |t|
      t.integer :post_id
      t.string :title
      t.date :from_date
      t.date :to_date
      t.timestamps
    end
  end
end
