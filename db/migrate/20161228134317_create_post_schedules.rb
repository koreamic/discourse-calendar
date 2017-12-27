class CreatePostSchedules < ActiveRecord::Migration[5.1]

  def self.up
    create_table :post_schedules do |t|
      t.integer :post_id
      t.integer :schedule_number, null: false
      t.string :title
      t.datetime :start_date_time, null: false
      t.datetime :end_date_time
      t.boolean :all_day, default: false
      t.timestamps
    end

    add_index :post_schedules, [:start_date_time, :end_date_time], :name => 'idx_post_schedules'
    add_index :post_schedules, [:post_id, :start_date_time, :end_date_time], :name => 'idx_post_schedules_posts'
  end

  def self.down
    drop_table :post_schedules
  end

end
