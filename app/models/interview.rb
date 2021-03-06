class Interview < ActiveRecord::Base
  include DateAndTimeMethods

  belongs_to :user
  belongs_to :application_record
  delegate :department,
           :position,
           to: :application_record

  validates :completed,
            :hired,
            inclusion: { in: [true, false], message: 'must be true or false' }
  validates :application_record,
            :location,
            :scheduled,
            :user,
            presence: true

  after_create :send_confirmation
  after_update :resend_confirmation

  default_scope { order :scheduled }
  scope :pending, -> { where completed: false }

  def calendar_title
    "Interview with #{user.full_name}"
  end

  def information(options = {})
    info = "#{format_date_time scheduled} at #{location}"
    info += ": #{user.proper_name}" if options.key? :include_name
    info
  end

  def pending?
    !completed
  end

  private

  def resend_confirmation
    if location_changed? || scheduled_changed?
      JobappsMailer.interview_reschedule self
    end
  end

  def send_confirmation
    JobappsMailer.interview_confirmation self
  end
end
