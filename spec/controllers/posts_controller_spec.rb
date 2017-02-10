require "rails_helper"
#require_relative "../helpers"

describe PostsController do
  let!(:user) { log_in }
  let!(:title) { "Testing Calendar Plugin" }

  before do
    SiteSetting.min_first_post_typing_time = 0
  end

  describe "schedule" do

    it "works" do
      xhr :post, :create, { title: title, raw: "[schedule title='Test Driven Development Conference' start_date_time=2017-01-02 end_date_time=2017-01-05 all_day=true timezone_offset=+09:00]\n- Location : LA\n- Contents\n 1. TEST1\n 2. TEST2\n[/schedule]" }
      expect(response).to be_success
      json = ::JSON.parse(response.body)
      
      expect(json["cooked"]).to match("discourse-calendar-schedule")
      expect(PostSchedule.where(title: 'Test Driven Development Conference').size).to eq(1)
    end

    it "works on any post" do
      post = Fabricate(:post)
      xhr :post, :create, { topic_id: post.topic.id, raw: "[schedule title='Test Driven Development Conference' start_date_time=2017-01-02 end_date_time=2017-01-05 all_day=true timezone_offset=+09:00]\n- Location : LA\n- Contents\n 1. TEST1\n 2. TEST2\n[/schedule]" }
      expect(response).to be_success
      json = ::JSON.parse(response.body)
      expect(json["cooked"]).to match("discourse-calendar-schedule")
      expect(PostSchedule.where(title: 'Test Driven Development Conference').size).to eq(1)
    end

    it "should have start date time" do
      xhr :post, :create, { title: title, raw: "[schedule title='Test Driven Development Conference' end_date_time=2017-01-05 all_day=true timezone_offset=+09:00]\n- Location : LA\n- Contents\n 1. TEST1\n 2. TEST2\n[/schedule]" }
      expect(response).not_to be_success
      json = ::JSON.parse(response.body)
      expect(json["errors"][0]).to eq(I18n.t("calendar.schedule.must_have_start_date_time"))
      expect(PostSchedule.where(title: 'Test Driven Development Conference').size).to eq(0)
    end

    it "should precede start date time before end date time" do
      xhr :post, :create, { title: title, raw: "[schedule title='Test Driven Development Conference' start_date_time=2017-10-01 end_date_time=2017-01-05 all_day=true timezone_offset=+09:00]\n- Location : LA\n- Contents\n 1. TEST1\n 2. TEST2\n[/schedule]" }
      expect(response).not_to be_success
      json = ::JSON.parse(response.body)
      expect(json["errors"][0]).to eq(I18n.t("calendar.schedule.validate_start_end_date_time"))
      expect(PostSchedule.where(title: 'Test Driven Development Conference').size).to eq(0)
    end
  end

  describe "multiple schedules" do
    it "work" do
      xhr :post, :create, { title: title, raw: "[schedule title='Test Driven Development Conference' start_date_time=2017-01-01T10:00 end_date_time=2017-01-01T11:00 all_day=false timezone_offset=+09:00]\n- Location : LA\n- Contents\n 1. TEST1\n 2. TEST2\n[/schedule]\n[schedule title='Test Driven Development Conference' start_date_time=2017-01-01T14:00 end_date_time=2017-10-01T15:00 all_day=false timezone_offset=+09:00]\n- Location : LA\n- Contents\n 1. TEST1\n 2. TEST2\n[/schedule]" }
      expect(response).to be_success
      expect(PostSchedule.where(title: 'Test Driven Development Conference').size).to eq(2)
    end
  end
end
