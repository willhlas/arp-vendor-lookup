require "test_helper"

class LookupsTest < ActionDispatch::IntegrationTest
  test "returns a cached lookup without hitting upstream" do
    Lookup.create!(mac: "AA:BB:CC:DD:EE:FF", vendor_name: "Example Vendor")

    get "/lookups", params: { mac: "aa:bb:cc:dd:ee:ff" }

    assert_response :success
    assert_equal "Example Vendor", JSON.parse(response.body)["vendor_name"]
  end

  test "fetches, persists, and returns vendor on a cache miss" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 200, body: [{ "company" => "Example Vendor" }].to_json)

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }

    assert_response :success
    assert Lookup.exists?(mac: "AA:BB:CC:DD:EE:FF", vendor_name: "Example Vendor")
  end

  test "returns 404 and caches a not-found result on upstream 204" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 204, body: "")

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }

    assert_response :not_found
    assert Lookup.exists?(mac: "AA:BB:CC:DD:EE:FF", vendor_name: nil)
  end

  test "returns 422 for a malformed mac" do
    get "/lookups", params: { mac: "not-a-mac" }

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["error"].present?
  end

  test "returns 502 when the upstream API is unreachable" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF").to_timeout

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }

    assert_response :bad_gateway
    assert_not Lookup.exists?(mac: "AA:BB:CC:DD:EE:FF")
  end

  test "GET /lookups with no mac returns recent lookups, newest first" do
    older = Lookup.create!(mac: "11:22:33:44:55:66", vendor_name: "Old Co")
    newer = Lookup.create!(mac: "AA:BB:CC:DD:EE:FF", vendor_name: "New Co")

    get "/lookups"

    assert_response :success
    assert_equal [newer.mac, older.mac], JSON.parse(response.body).map { |l| l["mac"] }
  end
end
