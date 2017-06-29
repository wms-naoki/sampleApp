class Task < ActiveRecord::Base
  include AASM
  belongs_to :user
  default_scope -> { order('created_at DESC') }
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true

  # Returns tasks from the users being followed by the given user.
  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
  end

  aasm column: :status do
    state :not_started, :initial => true
    state :working
    state :done

    event :start do
      transitions :from => :not_started, :to => :working
    end

    event :finish do
      transitions :from => :working, :to => :done
    end
  end
end