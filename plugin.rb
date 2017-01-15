# name: discourse-calendar
# about: A plug-in that allows you to register and lookup schedules.
# version: 0.0.1
# authors: koreamic

register_asset  "stylesheets/discourse-calendar.scss"
register_asset  "javascripts/vendor/fullcalendar/fullcalendar.js"
register_asset  "javascripts/vendor/fullcalendar/locale-all.js"

PLUGIN_NAME ||= "discourse-calendar".freeze

after_initialize do
  load File.expand_path(File.dirname(__FILE__)) << "/models/post_schedule.rb"  

  module ::DiscourseCalendar
    def self.filters
      @filters ||= [:latest, :unread, :new]
    end

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
          else
            if schedule.all_day
              schedule.end_date_time = schedule.end_date_time.end_of_day
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
          @post.errors.add(:base, I18n.t("calendar.schedule.must_have_start_date_time"))
          return false
        end
        true
      end

      def valid_date_times?(schedule)
        unless schedule.end_date_time.nil?
          if schedule.start_date_time >= schedule.end_date_time
            @post.errors.add(:base, I18n.t("calendar.schedule.validate_start_end_date_time"))
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
        schedule_pattern = /\[schedule(?:(?:\s+(?:title|start_date_time|end_date_time|all_day)=(?:['"][^\n]+['"]|[^\s\]]+))+)\]/
        attributes_pattern = /\w+=(?:['"][^\n]+['"]|[^\s\]]+)/

        raw.scan(schedule_pattern).each_with_index do |raw_schedule, index|
          schedule = {}
          schedule["schedule_number"] = index+1

          raw_schedule.scan(attributes_pattern).each do |attribute|
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
    get "/schedules" => "calendar#latest_schedules"
    get "/schedules/top" => "calendar#top_schedules"
    get "/schedules/categories" => "calendar#latest_schedules"
    get "/schedules/c/:category" => "calendar#category_latest_schedules"
    get "/schedules/c/:category/none" => "calendar#category_none_latest_schedules"
    get "/schedules/c/:parent_category/:category/(:id)" => "calendar#parent_category_category_latest_schedules", constraints: { id: /\d+/ }
    get "/schedules/c/:category/l/top" => "calendar#category_top_schedules", as: "calendar_category_top_schedules"
    get "/schedules/c/:category/none/l/top" => "calendar#category_none_top_schedules", as: "calendar_category_none_top_schedules"
    get "/schedules/c/:parent_category/:category/l/top" => "calendar#parent_category_category_top_schedules", as: "calendar_parent_category_category_top_schedules"

    TopTopic.periods.each do |period|
      get "/schedules/top/#{period}" => "calendar#top_#{period}_schedules"
      get "/schedules/c/:category/l/top/#{period}" => "calendar#category_top_#{period}_schedules", as: "calendar_schedule_category_top_#{period}_schedules"
      get "/schedules/c/:category/none/l/top/#{period}" => "calendar#category_none_top_#{period}_schedules", as: "calendar_schedule_category_none_top_#{period}_schedules"
      get "/schedules/c/:parent_category/:category/l/top/#{period}" => "calendar#parent_category_category_top_#{period}_schedules", as: "calendar_schedule_parent_category_category_top_#{period}_schedules"
    end

    DiscourseCalendar.filters.each do |filter|
      get "/schedules/#{filter}" => "calendar##{filter}_schedules", constraints: { format: /(json|html)/ }
      get "/schedules/c/:category/l/#{filter}" => "calendar#category_#{filter}_schedules", as: "calendar_schedule_category_#{filter}"
      get "/schedules/c/:category/none/l/#{filter}" => "calendar#category_none_#{filter}_schedules", as: "calendar_schedule_category_none_#{filter}_schedules"
      get "/schedules/c/:parent_category/:category/l/#{filter}" => "calendar#parent_category_category_#{filter}_schedules", as: "calendar_schedule_parent_category_category_#{filter}_schedules"
    end
  end

  Discourse::Application.routes.append do
    mount ::DiscourseCalendar::Engine, at: "/calendar"
  end

  require_dependency "list_controller"

  class DiscourseCalendar::CalendarController < ListController

    before_filter :set_category, only: [
      # filtered topics lists
      Discourse.filters.map { |f| :"category_#{f}_schedules" },
      Discourse.filters.map { |f| :"category_none_#{f}_schedules" },
      Discourse.filters.map { |f| :"parent_category_category_#{f}_schedules" },
      Discourse.filters.map { |f| :"parent_category_category_none_#{f}_schedules" },
      # top summaries
      :category_top_schedules,
      :category_none_top_schedules,
      :parent_category_category_top_schedules,
      # top pages (ie. with a period)
      TopTopic.periods.map { |p| :"category_top_#{p}_schedules" },
      TopTopic.periods.map { |p| :"category_none_top_#{p}_schedules" },
      TopTopic.periods.map { |p| :"parent_category_category_top_#{p}_schedules" },
    ].flatten

    before_filter :ensure_logged_in, except: [
      # anonymous filters
      Discourse.anonymous_filters.map { |f| :"#{f}_schedules" },
      # anonymous categorized filters
      Discourse.anonymous_filters.map { |f| :"category_#{f}_schedules" },
      Discourse.anonymous_filters.map { |f| :"category_none_#{f}_schedules" },
      Discourse.anonymous_filters.map { |f| :"parent_category_category_#{f}_schedules" },
      # top summaries
      :top_schedules,
      :category_top_schedules,
      :category_none_top_schedules,
      :parent_category_category_top_schedules,
      # top pages (ie. with a period)
      TopTopic.periods.map { |p| :"top_#{p}_schedules" },
      TopTopic.periods.map { |p| :"category_top_#{p}_schedules" },
      TopTopic.periods.map { |p| :"category_none_top_#{p}_schedules" },
      TopTopic.periods.map { |p| :"parent_category_category_top_#{p}_schedules" },
    ].flatten
    
    TopTopic.periods.each do |period|
      define_method("top_#{period}_schedules") do |options = {limit: false}|
        score = "#{period}_score"
        start_date = Date.strptime(params[:start], "%s")
        end_date = Date.strptime(params[:end], "%s")
        list_options = build_topic_list_options
        list_options.merge!(options) if options
        user = list_target_user

        topic_query = TopicQuery.new(user, list_options)
        #topic_results = topic_query.list_top_for(period).topics
        topic_results = topic_query.latest_results
        topic_results_top = topic_results.joins(:top_topic).where("top_topics.#{score} > 0")

        schedules = make_schedules(topic_results_top, start_date, end_date)

        render_json_dump(schedules: schedules)
      end

      define_method("category_top_#{period}_schedules") do
        self.send("top_#{period}_schedules", category: @category.id, limit: false)
      end
    
      define_method("category_none_top_#{period}_schedules") do
        self.send("top_#{period}_schedules", category: @category.id, no_subcategories: true, limit: false)
      end
    
      define_method("parent_category_category_top_#{period}_schedules") do
        self.send("top_#{period}_schedules", category: @category.id, limit: false)
      end
    end

    def top_schedules(options={limit: false})
      period = ListController.best_period_for(current_user.try(:previous_visit_at), options[:category])
      send("top_#{period}_schedules", options)
    end

    def category_top_schedules
      top_schedules(category: @category.id, limit: false)
    end

    def category_none_top_schedules
      top_schedules(category: @category.id, no_subcategories: true, limit: false)
    end

    def parent_category_category_top_schedules
      top_schedules(category: @category.id, limit: false)
    end

    DiscourseCalendar.filters.each do |filter|
      define_method("#{filter}_schedules") do |options={limit: false}|
        start_date = Date.strptime(params[:start], "%s")
        end_date = Date.strptime(params[:end], "%s")
        list_options = build_topic_list_options
        list_options.merge!(options) if options
        user = list_target_user

        topic_query = TopicQuery.new(user, list_options)
        topics = topic_query.public_send("#{filter}_results")

        schedules = make_schedules(topics, start_date, end_date)

        render_json_dump(schedules: schedules)
      end

      define_method("category_#{filter}_schedules") do
        canonical_url "#{Discourse.base_url_no_prefix}#{@category.url}"
        self.send("#{filter}_schedules", category: @category.id, limit: false)
      end
   
      define_method("category_none_#{filter}_schedules") do
        self.send("#{filter}_schedules", category: @category.id, no_subcategories: true, limit: false)
      end
   
      define_method("parent_category_category_#{filter}_schedules") do
        canonical_url "#{Discourse.base_url_no_prefix}#{@category.url}"
        self.send("#{filter}_schedules", category: @category.id, limit: false)
      end
   
    end

    private

    def make_schedules(topic_results, start_date, end_date)
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
            schedule[:title] = s.title.nil? || s.title.empty? ? t.title : s.title
            schedule[:start_date_time] = s.start_date_time.strftime("%Y-%m-%dT%H:%M:%S")
            schedule[:start] = s.start_date_time.strftime("%Y-%m-%dT%H:%M:%S")
            schedule[:end_date_time] = s.end_date_time.strftime("%Y-%m-%dT%H:%M:%S")
            schedule[:end] = s.end_date_time.strftime("%Y-%m-%dT%H:%M:%S")
            schedule[:allDay] = s.all_day
            schedules << schedule.clone
          end
        end
      end

      schedules
    end

  end

  validate(:post, :validate_schedules) do
    return if !SiteSetting.calendar_enabled? && (self.user && !self.user.staff?)
    
    return unless self.raw_changed?

    validator = DiscourseCalendar::ScheduleValidator::new(self)
    return unless (schedules = validator.validate_schedules)

    self.post_schedules = schedules

    true
  end
end
