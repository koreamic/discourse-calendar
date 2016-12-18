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
  
  module ::DiscourseCalendar
    autoload :PostSchedule, "#{Rails.root}/plugins/discourse-calendar/models/post_schedule"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseCalendar
    end
  end

  class DiscourseCalendar::Schedule
    class << self
      def validate_schedules(extracted_schedule)
        byebug
        puts extracted_schedule
      end

      def extract_schedules(raw, topic_id, user_id)
        extract_schedules = []

        schedule_pattern = /\[schedule(?:\s+(?:\w+=[^\s]+)\s*)*\].*\[\/schedule\]/
        title_pattern = /^\[schedule(?:\s+(?:\w+=[^\s]+)\s*)*\](.*)\[\/schedule\]$/
        header_pattern = /^\[schedule(?:\s+(?:\w+=[^\s\]]+)\s*)*\]/
        attributes_pattern = /\w+=[^\s\]]+/

        puts "into-raw-scan================================================"
        puts raw
        puts "into-raw-scan================================================"

        raw.scan(schedule_pattern).each_with_index { |raw_schedule, index|
          puts "into-raw-scan================================================"
          puts raw_schedule
          puts "into-raw-scan================================================"
          schedule = {}
          title = raw_schedule.scan(title_pattern).first.first;
          schedule["title"] = title
          #raw_schedule.scan(attributes_pattern)[0].split[1..-2].each { |attribute|
          raw_schedule.scan(header_pattern).first.scan(attributes_pattern).each { |attribute|
            byebug
            puts "into raw_schedule scan================================================"
            puts attribute
            puts "into raw_schedule scan================================================"
            key_value = attribute.split("=")
            schedule[key_value[0]] = key_value[1]
          }
          puts schedule
          extract_schedules << schedule
        }

        puts "================================================"
        puts extract_schedules
        puts "================================================"
        byebug

        extract_schedules
      end
    end
  end

  Post.class_eval do
    puts "calendar plugin post class_eval"
    has_many :post_schedules, class_name: "PostSchedule", dependent: :delete_all
    
    after_save do
      puts "calendar plugin post class eval after_save"

      puts self
      #puts self.post_schdules

    end
  end 

  validate(:post, :validate_schedules) do
    puts "poll plugin validate!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

    return if !SiteSetting.calendar_enabled? && (self.user && !self.user.staff?)
    
    # only care when raw has changed!
    return unless self.raw_changed?

    extracted_schedules = DiscourseCalendar::Schedule::extract_schedules(self.raw, self.topic_id, self.user_id)
    return unless (scedules = DiscourseCalendar::Schedule::validate_schedules(extracted_schedules))

    # are we updating a post?
    if self.id.present?
      puts "post id exists"
    else
      puts "post id not exists"
      #self.polls = polls
    end

    true
  end


end
