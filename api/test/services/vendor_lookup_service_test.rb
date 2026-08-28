require "test_helper"

class VendorLookupServiceTest < ActiveSupport::TestCase
  test "raises InvalidMacError for a malformed mac" do
    assert_raises(VendorLookupService::InvalidMacError) do
      VendorLookupService.new("not-a-mac").call
    end
  end

  test "normalizes hyphenated lowercase input before querying" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 200, body: [{ "company" => "Example Vendor" }].to_json)

    lookup = VendorLookupService.new("aa-bb-cc-dd-ee-ff").call

    assert_equal "AA:BB:CC:DD:EE:FF", lookup.mac
    assert_equal "Example Vendor", lookup.vendor_name
  end

  test "persists a not-found lookup on 204" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 204, body: "")

    lookup = VendorLookupService.new("AA:BB:CC:DD:EE:FF").call

    assert_not lookup.found?
  end

  test "raises UpstreamError on an unexpected status code" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 500, body: "")

    assert_raises(VendorLookupService::UpstreamError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF").call
    end
  end

  test "raises UpstreamError on malformed JSON" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 200, body: "not json")

    assert_raises(VendorLookupService::UpstreamError) do
      VendorLookupService.new("AA:BB:CC:DD:EE:FF").call
    end
  end

  test "reads from cache without an HTTP call" do
    Lookup.create!(mac: "AA:BB:CC:DD:EE:FF", vendor_name: "Cached Co")

    VendorLookupService.new("AA:BB:CC:DD:EE:FF").call

    assert_not_requested :get, /macvendorlookup/
  end
end
