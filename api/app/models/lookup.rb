class Lookup < ApplicationRecord
  MAC_FORMAT = /\A([0-9A-F]{2}:){5}[0-9A-F]{2}\z/
  RECENT_LIMIT = 20

  before_validation :normalize_mac

  validates :mac, presence: true, format: { with: MAC_FORMAT }, uniqueness: true

  scope :recent, -> { order(created_at: :desc).limit(RECENT_LIMIT) }

  def self.normalize_mac(value)
    hex = value.to_s.upcase.gsub(/[^0-9A-F]/, "")
    return value.to_s.upcase unless hex.length == 12

    hex.scan(/../).join(":")
  end

  def found?
    vendor_name.present?
  end

  private

  def normalize_mac
    self.mac = self.class.normalize_mac(mac)
  end
end
