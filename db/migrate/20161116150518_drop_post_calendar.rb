class DropPostCalendar < ActiveRecord::Migration
  def change
    drop_table :post_calendars
  end
end
