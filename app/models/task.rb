pclass Task < ActiveRecord::Base
  include AASM
  belongs_to :project
  has_many :dailies, dependent: :destroy
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

  DISPLAY_STATUS = {
    not_started: "未着手",
    working: "仕掛り",
    done: "完了"
  }

  def status_for_display
    DISPLAY_STATUS[self.status.to_sym]
  end
end