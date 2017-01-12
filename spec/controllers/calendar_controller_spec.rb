require "rails_helper"

describe ::DiscourseCalendar::CalendarController do
  routes { ::DiscourseCalendar::Engine.routes }

  context "anonymous user" do

    describe "top schedules" do
      before do
        xhr :get, "top_schedules", format: :json, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
      end
      it { is_expected.to respond_with(:success) }
    end

    (Discourse.anonymous_filters - [:categories]).each do |filter|
      describe "#{filter} schedules" do
        before do
          xhr :get, "#{filter}_schedules", format: :json, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
        end
        it { is_expected.to respond_with(:success) }
      end
    end

    TopTopic.periods.each do |period|
      describe "top #{period} schedules" do
        before do
          xhr :get, "top_#{period}_schedules", format: :json, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
        end
        it { is_expected.to respond_with(:success) }
      end
    end
    
    context "category" do
      let(:category) { Fabricate(:category) }

      describe "category top schedules" do
        before do
          xhr :get, "category_top_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
        end
        it { is_expected.to respond_with(:success) }
      end

      describe "category none top schedules" do
        before do
          xhr :get, "category_none_top_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
        end
        it { is_expected.to respond_with(:success) }
      end

      describe "child category top schedules" do
        let(:sub_category) { Fabricate(:category, parent_category_id: category.id) }

        before do
          xhr :get, "parent_category_category_top_schedules", format: :json, parent_category: category.slug, category: sub_category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
        end
        it { is_expected.to respond_with(:success) }
      end

      TopTopic.periods.each do |period|
        describe "top #{period} schedules" do
          before do
            xhr :get, "category_top_#{period}_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
          end
          it { is_expected.to respond_with(:success) }
        end

        describe "none top #{period} schedules" do
          before do
            xhr :get, "category_none_top_#{period}_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
          end
          it { is_expected.to respond_with(:success) }
        end

        describe "child category top #{period} schedules" do
          let(:sub_category) { Fabricate(:category, parent_category_id: category.id) }

          before do
            xhr :get, "parent_category_category_top_#{period}_schedules", format: :json, parent_category: category.slug, category: sub_category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
          end
          it { is_expected.to respond_with(:success) }
        end
      end

      (Discourse.anonymous_filters - [:categories]).each do |filter|
        describe "#{filter} schedules" do
          before do
            xhr :get, "category_#{filter}_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
          end
          it { is_expected.to respond_with(:success) }
        end

        describe "none #{filter} schedules" do
          before do
            xhr :get, "category_none_#{filter}_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
          end
          it { is_expected.to respond_with(:success) }
        end

        describe "child category #{filter} schedules" do
          let(:sub_category) { Fabricate(:category, parent_category_id: category.id) }

          before do
            xhr :get, "parent_category_category_#{filter}_schedules", format: :json, parent_category: category.slug, category: sub_category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
          end
          it { is_expected.to respond_with(:success) }
        end
      end

    end
  end

  context "login user" do
    let!(:user) { log_in }

    context "filter" do

      DiscourseCalendar.filters.each do |filter|

        describe "#{filter} schedules" do
          before do
            xhr :get, "#{filter}_schedules", format: :json, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
          end
          it { is_expected.to respond_with(:success) }
        end

      end
    end

    context "top" do
      TopTopic.periods.each do |period|

        describe "#{period} schedules" do
          before do
            xhr :get, "top_#{period}_schedules", format: :json, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
          end

          it { is_expected.to respond_with(:success) }
        end

      end
    end

    context "category" do
      let(:category) { Fabricate(:category) }

      context "filter schedules" do
        DiscourseCalendar.filters.each do |filter|
          describe "category #{filter}" do
            before do
              xhr :get, "category_#{filter}_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
            end

            it { is_expected.to respond_with(:success) }
          end

          describe "none #{filter} schedules" do
            before do
              xhr :get, "category_none_#{filter}_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
            end

            it { is_expected.to respond_with(:success) }
          end

          describe "child category #{filter} schedules" do
            let(:sub_category) { Fabricate(:category, parent_category_id: category.id) }

            before do
              xhr :get, "parent_category_category_#{filter}_schedules", format: :json, parent_category: category.slug, category: sub_category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
            end

            it { is_expected.to respond_with(:success) }
          end
        end
      end

      context "top" do
        TopTopic.periods.each do |period|
          describe "#{period} schedules" do
            before do
              xhr :get, "category_top_#{period}_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
            end

            it { is_expected.to respond_with(:success) }
          end

          describe "none #{period} schedules" do
            before do
              xhr :get, "category_none_top_#{period}_schedules", format: :json, category: category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
            end

            it { is_expected.to respond_with(:success) }
          end

          describe 'child category' do
            let(:sub_category) { Fabricate(:category, parent_category_id: category.id) }
            
            before do
              xhr :get, "parent_category_category_top_#{period}_schedules", format: :json, parent_category: category.slug, category: sub_category.slug, start: "#{Date.today.beginning_of_month.strftime('%s')}", end: "#{Date.today.end_of_month.strftime('%s')}"
            end

            it { is_expected.to respond_with(:success) }
          end
        end
      end
    end
  end
end
