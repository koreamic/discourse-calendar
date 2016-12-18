class ReReReReRecreatePostSchedule < ActiveRecord::Migration
  def change
    drop_table :post_schedules

    create_table :post_schedules do |t|
      t.integer :post_id
      t.integer :schedule_number, null: false
      t.string :title
      t.datetime :start_date_time, null: false
      t.datetime :end_date_time
      t.boolean :all_day, default: false
      t.timestamps
    end
  end
end
