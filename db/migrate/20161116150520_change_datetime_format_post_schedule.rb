class ChangeDatetimeFormatPostSchedule < ActiveRecord::Migration
  def up
    add_column :post_schedules, :start, :datetime
    add_column :post_schedules, :end, :datetime
  end
  def down
    remove_column :post_schedules, :start, :datetime
    remove_column :post_schedules, :start, :datetime
  end
end
