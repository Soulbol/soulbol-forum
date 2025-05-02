module Thredded
  class UserTopicFollow < ActiveRecord::Base
    enum reason: { posted: 0, manual: 1, mentioned: 2 }

    belongs_to :user, class_name: Thredded.user_class_name
    belongs_to :topic, class_name: 'Thredded::Topic'

    validates :user_id, presence: true
    validates :topic_id, presence: true

    # Alias topic_id to postable_id
    alias_attribute :postable_id, :topic_id

    # Alias topic to postable
    def postable
      topic
    end

    def postable=(value)
      self.topic = value
    end

    # Creates a follow if one doesn't exist, in a thread-safe way.
    def self.create_unless_exists(user_id, topic_id, reason)
      follow = where(user_id: user_id, topic_id: topic_id).first_or_initialize
      follow.reason = reason
      follow.save!
      follow
    rescue ActiveRecord::RecordNotUnique
      # The record has been created from another thread, find and return it
      find_by!(user_id: user_id, topic_id: topic_id)
    end
  end
end 