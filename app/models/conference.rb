class Conference < ActiveRecord::Base
  extend FriendlyId
  attr_accessible :active, :call_for_papers_enabled, :call_for_papers_end_date, :call_for_papers_start_date, :coordinator, :description, :end_date, :location, :slug, :start_date, :title, :voting_enabled, :voting_end_date, :voting_start_date
  has_many :events
  validates_presence_of :title, :description
  validates_uniqueness_of :title
  friendly_id :title, use: :slugged

  private
  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end
end
