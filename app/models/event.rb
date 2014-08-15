class Event < ActiveRecord::Base
  extend FriendlyId
  acts_as_taggable
 attr_accessible :accepted, :active, :assisted_by, :brief_description, :comments, :conference_id, :content_url, :date, :description, :email, :end_time, :id, :language, :level, :location, :room, :slug, :start_time, :speaker, :subclass, :tags, :title, :votes, :cancelled
  attr_accessor :tags
  belongs_to :conference
  friendly_id :title, use: [:slugged, :scoped], scope: :conference

  TOKEN_LENGTH=32

  validates :title,
            format: { with: /\A[a-z0-9\W]+\z/i },
            presence: true,
            uniqueness: { scope: :conference }

  validates :brief_description,
            format: { with: /\A[a-z0-9\W]+\z/i },
            presence: true

  validates :description,
            format: { with: /\A[a-z0-9\W]+\z/i },
            presence: true

  validates :content_url,
            url: true,
            allow_blank: true

  validates :speaker,
            allow_blank: true,
            format: { with: /\A[a-z\W]+\z/i }

  validates :email,
            email: true,
            allow_blank: true

  validates :comments,
            allow_blank: true,
            format: { with: /\A[a-z0-9\W]+\z/i }

  validates :language,
            allow_blank: true,
            inclusion: { in: I18n.t("event.languages").keys.collect {|l| l.to_s} }

  enum level: [:noob, :easy, :medium, :hard, :hacker]
  enum subclass: [:talk, :workshop]
  
  #validates :terms_of_service, acceptance: { accept: 'yes' }

  #before_create :lang_filter

  after_create :verify_event


  #def to_ics
  #  event = Icalendar::Event.new
  #  event.start = self.date.strftime("%Y%m%dT%H%M%S")
  #  event.end = self.end_date.strftime("%Y%m%dT%H%M%S")
  #  event.summary = self.title
  #  event.description = self.summary
  #  event.location = self.location
  #  event.klass = "PUBLIC"
  #  event.created = self.created_at
  #  event.last_modified = self.updated_at
  #  event.uid = event.url = "#{PUBLIC_URL}events/#{self.id}"
  #  event.add_comment("AF83 - Shake your digital, we do WowWare")
  #  event
  #end


  private
  #def generate_token
  #    self.t = SecureRandom.urlsafe_base64(32, false)
  #    generate_token if VerifyEvent.exist?(token: self.token)
  #end

  def generate_token
        t = SecureRandom.urlsafe_base64
        t
  end

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end

  def verify_event
      unless self.email.blank?
        token = generate_token
        Notifier.confirmation_event(self, token).deliver
      end
  end
end
