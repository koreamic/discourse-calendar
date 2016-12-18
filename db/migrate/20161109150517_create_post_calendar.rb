class CreatePostCalendar < ActiveRecord::Migration
  def change
    create_table :post_calendars do |t|
      t.integer :post_id
      t.date :from_date
      t.date :to_date
      t.timestamps
    end
  end
end
