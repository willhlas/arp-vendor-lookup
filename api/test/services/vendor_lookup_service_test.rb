require "test_helper"

class VendorLookupServiceTest < ActiveSupport::TestCase
  test "raises InvalidMacError for a malformed mac" do
    assert_raises(VendorLookupService::InvalidMacError) do
      VendorLookupService.new("not-a-mac", "192.168.1.24").call
    end
  end

  test "raises InvalidIpError for a malformed ip" do
    assert_raises(VendorLookupService::InvalidIpError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "not-an-ip").call
    end
  end

  test "raises InvalidIpError for a blank ip" do
    assert_raises(VendorLookupService::InvalidIpError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "").call
    end
  end

  test "normalizes hyphenated lowercase input before querying" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 200, body: [ { "company" => "Example Vendor" } ].to_json)

    lookup = VendorLookupService.new("aa-bb-cc-dd-ee-ff", "192.168.1.24").call

    assert_equal "AA:BB:CC:DD:EE:FF", lookup.mac
    assert_equal "Example Vendor", lookup.vendor_name
    assert_equal "192.168.1.24", lookup.ip
  end

  test "persists a not-found lookup on 204" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 204, body: "")

    lookup = VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call

    assert_not lookup.found?
  end

  test "raises UpstreamBadResponseError on an unexpected status code" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 500, body: "")

    assert_raises(VendorLookupService::UpstreamBadResponseError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call
    end
  end

  test "raises UpstreamBadResponseError on malformed JSON" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 200, body: "not json")

    assert_raises(VendorLookupService::UpstreamBadResponseError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call
    end
  end

  test "raises UpstreamRateLimitedError on a 429" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 429, body: "")

    assert_raises(VendorLookupService::UpstreamRateLimitedError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call
    end
  end

  test "raises UpstreamUnavailableError on a timeout" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF").to_timeout

    assert_raises(VendorLookupService::UpstreamUnavailableError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call
    end
  end

  test "raises UpstreamUnavailableError on a SocketError" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_raise(SocketError)

    assert_raises(VendorLookupService::UpstreamUnavailableError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call
    end
  end

  test "raises UpstreamUnavailableError on an SSL error" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_raise(OpenSSL::SSL::SSLError)

    assert_raises(VendorLookupService::UpstreamUnavailableError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call
    end
  end

  test "reads from cache without an HTTP call" do
    Lookup.create!(mac: "AA:BB:CC:DD:EE:FF", ip: "192.168.1.24", vendor_name: "Cached Co")

    VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call

    assert_not_requested :get, /macvendorlookup/
  end

  test "looking up an already-cached mac from a new ip updates the cached ip" do
    cached = Lookup.create!(mac: "AA:BB:CC:DD:EE:FF", ip: "192.168.1.24", vendor_name: "Cached Co")

    lookup = VendorLookupService.new("AA:BB:CC:DD:EE:FF", "10.0.0.5").call

    assert_equal cached.id, lookup.id
    assert_equal "10.0.0.5", lookup.ip
    assert_equal "10.0.0.5", cached.reload.ip
  end

  test "recovers from a concurrent create for the same mac" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 200, body: [ { "company" => "Example Vendor" } ].to_json)

    lookup = with_racing_lookup_create do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF", "192.168.1.24").call
    end

    assert_equal "Example Vendor", lookup.vendor_name
    assert_equal 1, Lookup.where(mac: "AA:BB:CC:DD:EE:FF").count
  end

  private

  # Simulates another request inserting the same mac between our find_by
  # miss and our create!, by making create! itself perform that insert
  # (via #save!, which isn't overridden) and then raise the same uniqueness
  # error a real race would produce.
  def with_racing_lookup_create
    Lookup.define_singleton_method(:create!) do |mac:, ip:, vendor_name:|
      Lookup.new(mac: mac, ip: ip, vendor_name: vendor_name).save!
      raise ActiveRecord::RecordInvalid, Lookup.new
    end
    yield
  ensure
    Lookup.singleton_class.send(:remove_method, :create!)
  end
end
