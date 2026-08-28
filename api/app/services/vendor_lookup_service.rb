require "net/http"
require "json"

class VendorLookupService
  class Error < StandardError; end
  class InvalidMacError < Error; end
  class UpstreamError < Error; end

  ENDPOINT = "https://www.macvendorlookup.com/api/v2/%s"

  def initialize(raw_mac)
    @raw_mac = raw_mac
  end

  def call
    mac = Lookup.normalize_mac(@raw_mac)
    unless mac.match?(Lookup::MAC_FORMAT)
      raise InvalidMacError, "mac must be a full 6-octet address, e.g. AA:BB:CC:DD:EE:FF"
    end

    Lookup.find_by(mac: mac) || fetch_and_persist(mac)
  end

  private

  def fetch_and_persist(mac)
    Lookup.create!(mac: mac, vendor_name: fetch_vendor_name(mac))
  end

  def fetch_vendor_name(mac)
    response = http_get(mac)
    case response
    when Net::HTTPNoContent then nil
    when Net::HTTPSuccess then parse_vendor_name(response.body)
    else raise UpstreamError, "vendor lookup API returned #{response.code}"
    end
  rescue Timeout::Error, SocketError, SystemCallError => e
    raise UpstreamError, "vendor lookup API unreachable: #{e.message}"
  end

  def http_get(mac)
    uri = URI(format(ENDPOINT, mac))
    Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 5) do |http|
      http.get(uri)
    end
  end

  def parse_vendor_name(body)
    JSON.parse(body).first.fetch("company")
  rescue JSON::ParserError, NoMethodError, KeyError => e
    raise UpstreamError, "unexpected vendor lookup API response: #{e.message}"
  end
end
