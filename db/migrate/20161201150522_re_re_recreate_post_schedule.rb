class ReReRecreatePostSchedule < ActiveRecord::Migration
  def change
    drop_table :post_schedules

    create_table :post_schedules do |t|
      t.integer :post_id
      t.string :title
      t.date :start_date, null: false
      t.time :start_time
      t.date :end_date
      t.time :end_time
      t.boolean :all_day, default: false
      t.timestamps
    end
  end
end
