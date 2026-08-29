require "net/http"
require "json"
require "resolv"

class VendorLookupService
  class Error < StandardError; end
  class InvalidMacError < Error; end
  class InvalidIpError < Error; end
  class UpstreamError < Error; end
  class UpstreamUnavailableError < UpstreamError; end
  class UpstreamBadResponseError < UpstreamError; end
  class UpstreamRateLimitedError < UpstreamBadResponseError; end

  ENDPOINT = "https://www.macvendorlookup.com/api/v2/%s"

  def initialize(raw_mac, raw_ip)
    @raw_mac = raw_mac
    @raw_ip = raw_ip
  end

  def call
    mac = Lookup.normalize_mac(@raw_mac)
    unless mac.match?(Lookup::MAC_FORMAT)
      raise InvalidMacError, "mac must be a full 6-octet address, e.g. AA:BB:CC:DD:EE:FF"
    end

    unless @raw_ip.to_s.match?(Resolv::IPv4::Regex)
      raise InvalidIpError, "ip must be a valid IPv4 address, e.g. 192.168.1.24"
    end

    lookup = Lookup.find_by(mac: mac)
    if lookup
      lookup.update!(ip: @raw_ip)
      lookup
    else
      fetch_and_persist(mac, @raw_ip)
    end
  end

  private

  def fetch_and_persist(mac, ip)
    Lookup.create!(mac: mac, ip: ip, vendor_name: fetch_vendor_name(mac))
  rescue ActiveRecord::RecordInvalid
    Lookup.find_by!(mac: mac).tap { |lookup| lookup.update!(ip: ip) }
  end

  def fetch_vendor_name(mac)
    response = http_get(mac)
    case response
    when Net::HTTPNoContent then nil
    when Net::HTTPSuccess then parse_vendor_name(response.body)
    when Net::HTTPTooManyRequests
      raise UpstreamRateLimitedError, "vendor lookup API rate-limited us (429)"
    else raise UpstreamBadResponseError, "vendor lookup API returned #{response.code}"
    end
  rescue Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
    raise UpstreamUnavailableError, "vendor lookup API unreachable: #{e.message}"
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
    raise UpstreamBadResponseError, "unexpected vendor lookup API response: #{e.message}"
  end
end
