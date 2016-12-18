# name: discourse-calendar
# about: A super simple plugin to demonstrate how plugins work
# version: 0.0.1
# authors: Awesome Plugin Developer

register_asset  "stylesheets/discourse-calendar.scss"
register_asset  "javascripts/vendor/fullcalendar/fullcalendar.js"

PLUGIN_NAME ||= "discourse-calendar".freeze

after_initialize do
  load File.expand_path(File.dirname(__FILE__)) << '/models/post_schedule.rb'  

  module ::DiscourseCalendar
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseCalendar
    end
 
    class DiscourseCalendar::ScheduleValidator
      def initialize(post)
        @post = post
      end

      def validate_schedules
        schedules = []
        extracted_schedules = DiscourseCalendar::Schedule::extract(@post.raw)

        extracted_schedules.each do |extracted_schedule|
          schedule = PostSchedule.new(extracted_schedule)
          return false unless start_date_time_not_nil?(schedule)
          if schedule.end_date_time.nil?
            if schedule.all_day
              schedule.start_date_time = schedule.start_date_time.beginning_of_day
              schedule.end_date_time = schedule.start_date_time.end_of_day
            else
              schedule.end_date_time = schedule.start_date_time + 1.hours
            end
          end
          return false unless valid_date_times?(schedule)
          schedules << schedule
        end

        schedules
      end

      private

      def start_date_time_not_nil?(schedule)
        if schedule.start_date_time.nil?
          #@post.errors.add(:base, I18n.t("poll.multiple_polls_without_name"))
          @post.errors.add(:base, I18n.t("caledar.schedule.default_schedule_must_have_start_date_time"))
          return false
        end
        true
      end

      def valid_date_times?(schedule)
        unless schedule.end_date_time.nil?
          if schedule.start_date_time >= schedule.end_date_time
            #@post.errors.add(:base, I18n.t("poll.multiple_polls_without_name"))
            @post.errors.add(:base, I18n.t("caledar.schedule.validate_start_end_date_time"))
            return false
          end
        end

        true
      end

    end
  end

  class DiscourseCalendar::Schedule
    class << self
      def extract(raw)
        extracted_schedules = []

        schedule_pattern = /\[schedule(?:\s+(?:\w+=[^\s]+)\s*)*\].*\[\/schedule\]/
        title_pattern = /^\[schedule(?:\s+(?:\w+=[^\s]+)\s*)*\](.*)\[\/schedule\]$/
        header_pattern = /^\[schedule(?:\s+(?:\w+=[^\s\]]+)\s*)*\]/
        attributes_pattern = /\w+=[^\s\]]+/

        raw.scan(schedule_pattern).each_with_index do |raw_schedule, index|
          schedule = {}
          schedule["schedule_number"] = index+1
          #byebug

          title = raw_schedule.scan(title_pattern).first.first;
          schedule["title"] = title

          raw_schedule.scan(header_pattern).first.scan(attributes_pattern).each do |attribute|
            key_value = attribute.split("=")
            schedule[key_value[0]] = key_value[1]
          end
          puts schedule
          extracted_schedules << schedule.slice("schedule_number", "title", "start_date_time", "end_date_time", "all_day")
        end

        puts "================================================"
        puts extracted_schedules
        puts "================================================"

        extracted_schedules
      end
    end
  end

  Post.class_eval do
    puts "calendar plugin post class_eval"
    has_many :post_schedules, class_name: "PostSchedule", dependent: :delete_all
    
    after_save do
      puts "calendar plugin post class eval after_save"

      #puts self.post_schdules
      puts self
    end

    #after_save do
      #return if !SiteSetting.calendar_enabled? && (self.user && !self.user.staff?)
      #return unless self.raw_changed?

      #extracted_schedules = DiscourseCalendar::Schedule::extract(self.raw, self.topic_id, self.user_id)
      #return unless (schedules = DiscourseCalendar::Schedule::validate(extracted_schedules))
    #end
  end 
  
  DiscourseCalendar::Engine.routes.draw do
    get "/schedules" => "calendar#schedules"
  end

  Discourse::Application.routes.append do
    mount ::DiscourseCalendar::Engine, at: "/calendar"
  end

  require_dependency "application_controller"

  class DiscourseCalendar::CalendarController < ::ApplicationController

    def schedules

      start_date = Date.strptime(params[:start], '%s')
      end_date = Date.strptime(params[:end], '%s')

      category = params[:category];
      results_options = {:limit => false, :category =>  category}
      user = current_user

      #TODO method로 분리
      topic_query = TopicQuery.new(user, results_options)
      topic_results = topic_query.latest_results
      topic_post_results = topic_results.joins(:posts)
      topic_post_schedule_results = topic_post_results.joins("INNER JOIN post_schedules ON (posts.id = post_schedules.post_id)")
      topic_post_schedule_month_results = topic_post_schedule_results.where("post_schedules.start_date_time < ?", end_date).where("post_schedules.end_date_time >= ?", start_date)
      schedules = []

      topic_post_schedule_month_results.each do |t|
        schedule = {}
        schedule[:topic_title] = t.title
        schedule[:topic_id] = t.id
        schedule[:color] = t.category.color ? "\##{t.category.color}" : "#{SiteSetting.calendar_schedule_default_color}"
        
        t.posts.each do |p|
          schedule[:post_id] = p.id
          schedule[:post_url] = p.url
          schedule[:url] = p.url
          schedule[:post_full_url] = p.url

          p.post_schedules.each do |s|
            schedule[:id] = s.id
            schedule[:title] = s.title ? s.title : t.title
            schedule[:start_date_time] = s.start_date_time.strftime("%Y-%m-%dT%H:%M:%S")
            schedule[:start] = s.start_date_time.strftime("%Y-%m-%dT%H:%M:%S")
            schedule[:end_date_time] = s.end_date_time.strftime("%Y-%m-%dT%H:%M:%S")
            schedule[:end] = s.end_date_time.strftime("%Y-%m-%dT%H:%M:%S")
            schedule[:allDay] = s.all_day
            schedules << schedule.clone
          end
        end
      end

      render_json_dump(schedules: schedules)

    end
  end

  validate(:post, :validate_schedules) do
    return if !SiteSetting.calendar_enabled? && (self.user && !self.user.staff?)
    
    # only care when raw has changed!
    return unless self.raw_changed?

    validator = DiscourseCalendar::ScheduleValidator::new(self)
    return unless (schedules = validator.validate_schedules)

    #puts "post_schedules #{schedules}"
    # are we updating a post?
    # TODO 더 멋있게 할 수 없을까?
    #if self.id.present?
      #puts "post id exists"
      #previous_schedules = self.post_schedules || {}
      #byebug

    #else
      #puts "post id not exists"
      #self.post_schedules = schedules
    #end

    # all delete all insert
    self.post_schedules = schedules

    true
  end
end
