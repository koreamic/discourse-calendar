# name: discourse-calendar
# about: A super simple plugin to demonstrate how plugins work
# version: 0.0.1
# authors: Awesome Plugin Developer

register_asset  "stylesheets/discourse-calendar.scss"
register_asset  "javascripts/vendor/fullcalendar/fullcalendar.js"

PLUGIN_NAME ||= "discourse-calendar".freeze

after_initialize do
  puts "calendar plugin initialize"
  puts "PostCalendar class Define"
  puts "#{Rails.root}"

  autoload :PostSchedule, "#{Rails.root}/plugins/discourse-calendar/models/post_schedule"

  #PostCalendar.new
  #puts PostCalendar

  #class PostCalendar < ActiveRecord::Base
    #belongs_to :post
  #end

  Post.class_eval do
    puts "calendar plugin post class_eval"
    has_many :post_schedule, class_name: "PostSchedule", dependent: :delete_all
  end 
  
end
