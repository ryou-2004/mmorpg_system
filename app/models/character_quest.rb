class CharacterQuest < ApplicationRecord
  belongs_to :character
  belongs_to :quest

  validates :character_id, uniqueness: { scope: :quest_id }
  validates :status, presence: true, inclusion: { in: %w[started in_progress completed failed abandoned] }

  scope :active, -> { where(status: %w[started in_progress]) }
  scope :completed, -> { where(status: "completed") }
  scope :failed, -> { where(status: "failed") }
  scope :by_status, ->(status) { where(status: status) }

  def status_name
    case status
    when "started" then "開始済み"
    when "in_progress" then "進行中"
    when "completed" then "完了"
    when "failed" then "失敗"
    when "abandoned" then "放棄"
    else status
    end
  end

  def duration
    return nil unless completed_at && started_at
    completed_at - started_at
  end

  def completed?
    status == "completed"
  end

  def active?
    %w[started in_progress].include?(status)
  end

  def update_progress!(progress_data)
    update!(
      progress: progress.merge(progress_data),
      status: determine_status_from_progress(progress_data)
    )
  end

  private

  def determine_status_from_progress(progress_data)
    return "completed" if progress_data[:completed] == true
    return "failed" if progress_data[:failed] == true
    return "in_progress" if progress_data.any? { |_, v| v.present? }
    "started"
  end
end
