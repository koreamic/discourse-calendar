class PostSchedule < ActiveRecord::Base
  belongs_to :post, class_name: "Post", foreign_key: :post_id
  belongs_to :topic, class_name: "Topic", foreign_key: :topic_id
end
