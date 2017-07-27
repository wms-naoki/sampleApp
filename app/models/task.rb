class Task < ActiveRecord::Base
  include AASM
  belongs_to :project
  default_scope -> { order('created_at DESC') }
  validates :content, presence: true, length: { maximum: 140 }

  aasm column: :status do
    state :not_started, initial: true
    state :working
    state :done

    event :start do
      transitions from: :not_started, to: :working
    end

    event :finish do
      transitions from: :working, to: :done
    end
  end
end