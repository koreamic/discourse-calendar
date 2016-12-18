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
          @post.errors.add(:base, I18n.t("caledar.schedule.default_schedule_must_have_start_date_time"))
          return false
        end
        true
      end

      def valid_date_times?(schedule)
        unless schedule.end_date_time.nil?
          if schedule.start_date_time >= schedule.end_date_time
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

        schedule_pattern = /\[schedule(?:\s+(?:\w+=(?:['"][\S\s^\]]+['"]|['"]?[^\s\]]+['"]?))*\s*)*\][\s\S]*\[\/schedule\]/
        header_pattern = /^\[schedule(?:\s+(?:\w+=(?:['"][\S\s^\]]+['"]|['"]?[^\s\]]+['"]?))*\s*)*\]/
        attributes_pattern = /\w+=(?:['"][\S\s^\]]+['"]|['"]?[^\s\]]+['"]?)/

        raw.scan(schedule_pattern).each_with_index do |raw_schedule, index|
          schedule = {}
          schedule["schedule_number"] = index+1

          raw_schedule.scan(header_pattern).first.scan(attributes_pattern).each do |attribute|
            index = attribute.index("=")
            key = attribute[0, index]
            value = attribute[index+1..-1]

            if (value[0] == "'" && value[-1] == "'") || (value[0] == "\"" && value[-1] == "\"")
              value = value[1..-2]
           end

            schedule[key] = value
          end

          extracted_schedules << schedule.slice("schedule_number", "title", "start_date_time", "end_date_time", "all_day")
        end

        extracted_schedules
      end
    end
  end

  Post.class_eval do
    has_many :post_schedules, class_name: "PostSchedule", dependent: :delete_all
  end 
  
  DiscourseCalendar::Engine.routes.draw do
    get "/schedules" => "calendar#schedules"
    get "/schedules/c/:category" => "calendar#category_latest"
    get "/schedules/c/:category/none" => "calendar#category_none_latest"
    get "/schedules/c/:parent_category/:category/(:id)" => "calendar#parent_category_category_latest", constraints: { id: /\d+/ }
    get "/schedules/c/:category/l/top" => "calendar#category_top", as: "calendar_schedule_category_top"
    get "/schedules/c/:category/none/l/top" => "calendar#category_none_top", as: "calendar_schedule_category_none_top"
    get "/schedules/c/:parent_category/:category/l/top" => "calendar#parent_category_category_top", as: "calendar_schedule_parent_category_category_top"

    TopTopic.periods.each do |period|
      get "/schedules/top/#{period}" => "calendar#top_#{period}"
      get "/schedules/c/:category/l/top/#{period}" => "calendar#category_top_#{period}", as: "calendar_schedule_category_top_#{period}"
      get "/schedules/c/:category/none/l/top/#{period}" => "calendar#category_none_top_#{period}", as: "calendar_schedule_category_none_top_#{period}"
      get "/schedules/c/:parent_category/:category/l/top/#{period}" => "calednar#parent_category_category_top_#{period}", as: "calendar_schedule_parent_category_category_top_#{period}"
    end

    Discourse.filters.each do |filter|
      get "/schedules/#{filter}" => "calendar##{filter}", constraints: { format: /(json|html)/ }
      get "/schedules/c/:category/l/#{filter}" => "calendar#category_#{filter}", as: "calendar_schedule_category_#{filter}"
      get "/schedules/c/:category/none/l/#{filter}" => "calendar#category_none_#{filter}", as: "calendar_schedule_category_none_#{filter}"
      get "/schedules/c/:parent_category/:category/l/#{filter}" => "calendar#parent_category_category_#{filter}", as: "calendar_schedule_parent_category_category_#{filter}"
    end
  end

  Discourse::Application.routes.append do
    mount ::DiscourseCalendar::Engine, at: "/calendar"
  end

  require_dependency "application_controller"
  require_dependency "list_controller"

  #class DiscourseCalendar::CalendarController < ::ApplicationController
  class DiscourseCalendar::CalendarController < ListController
    #include ApplicationController::ListController
    #include ListController::ApplicationController

    before_filter :set_category, only: [
      # filtered topics lists
      Discourse.filters.map { |f| :"category_#{f}" },
      Discourse.filters.map { |f| :"category_none_#{f}" },
      Discourse.filters.map { |f| :"parent_category_category_#{f}" },
      Discourse.filters.map { |f| :"parent_category_category_none_#{f}" },
      # top summaries
      :category_top,
      :category_none_top,
      :parent_category_category_top,
      # top pages (ie. with a period)
      TopTopic.periods.map { |p| :"category_top_#{p}" },
      TopTopic.periods.map { |p| :"category_none_top_#{p}" },
      TopTopic.periods.map { |p| :"parent_category_category_top_#{p}" },

    ].flatten
    
    TopTopic.periods.each do |period|
      define_method("category_top_#{period}") do
        self.send("schedules_#{period}", category: @category.id, limit: false)
      end
    
      define_method("category_none_top_#{period}") do
        self.send("schedules_#{period}", category: @category.id, no_subcategories: true, limit: false)
      end
    
      define_method("parent_category_category_top_#{period}") do
        self.send("schedules_#{period}", category: @category.id, limit: false)
      end
    end

    Discourse.filters.each do |filter|
      define_method("category_#{filter}") do
        canonical_url "#{Discourse.base_url_no_prefix}#{@category.url}"
        self.send("schedules", category: @category.id, limit: false)
      end
   
      define_method("category_none_#{filter}") do
        self.send("schedules", category: @category.id, no_subcategories: true, limit: false)
      end
   
      define_method("parent_category_category_#{filter}") do
        canonical_url "#{Discourse.base_url_no_prefix}#{@category.url}"
        self.send("schedules", category: @category.id, limit: false)
      end
   
      define_method("parent_category_category_none_#{filter}") do
        self.send("schedules", category: @category.id, limit: false)
      end
    end

    def category_top
      schedules(category: @category.id, limit: false)
    end

    def category_none_top
      schedules(category: @category.id, no_subcategories: true, limit: false)
    end

    def parent_category_category_top
      schedules(category: @category.id, limit: false)
    end

    def schedules(options = {limit: false})
      list_options = build_topic_list_options
      list_options.merge!(options) if options

      start_date = Date.strptime(params[:start], '%s')
      end_date = Date.strptime(params[:end], '%s')
      
      user = list_target_user
      
      #TODO method로 분리
      topic_query = TopicQuery.new(user, list_options)
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

    self.post_schedules = schedules

    true
  end
end
