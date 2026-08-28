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
      .to_return(status: 200, body: [ { "company" => "Example Vendor" } ].to_json)

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

  test "returns the cached 404 on a second request without hitting upstream again" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 204, body: "")

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }
    assert_response :not_found

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }

    assert_response :not_found
    assert_requested :get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF", times: 1
  end

  test "returns 422 for a malformed mac" do
    get "/lookups", params: { mac: "not-a-mac" }

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["error"].present?
  end

  test "returns 422 for a blank mac param" do
    get "/lookups", params: { mac: "" }

    assert_response :unprocessable_entity
    assert JSON.parse(response.body)["error"].present?
  end

  test "returns 422 for a mac with the wrong octet count" do
    get "/lookups", params: { mac: "AA:BB:CC:DD:EE" }

    assert_response :unprocessable_entity
  end

  test "returns 422 for a mac with non-hex characters at the right length" do
    get "/lookups", params: { mac: "ZZ:ZZ:ZZ:ZZ:ZZ:ZZ" }

    assert_response :unprocessable_entity
  end

  test "returns 503 when the upstream API is unreachable" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF").to_timeout

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }

    assert_response :service_unavailable
    assert_not Lookup.exists?(mac: "AA:BB:CC:DD:EE:FF")
  end

  test "returns 502 when the upstream API returns an unexpected status" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 500, body: "")

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }

    assert_response :bad_gateway
    assert JSON.parse(response.body)["error"].present?
  end

  test "returns 502 when the upstream API returns malformed JSON" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 200, body: "not json")

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }

    assert_response :bad_gateway
  end

  test "returns 429 when the upstream API rate-limits us" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 429, body: "")

    get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }

    assert_response :too_many_requests
  end

  test "recovers from a concurrent create for the same mac" do
    stub_request(:get, "https://www.macvendorlookup.com/api/v2/AA:BB:CC:DD:EE:FF")
      .to_return(status: 200, body: [ { "company" => "Example Vendor" } ].to_json)

    with_racing_lookup_create do
      get "/lookups", params: { mac: "AA:BB:CC:DD:EE:FF" }
    end

    assert_response :success
    assert_equal "Example Vendor", JSON.parse(response.body)["vendor_name"]
  end

  test "GET /lookups with no mac returns recent lookups, newest first" do
    older = Lookup.create!(mac: "11:22:33:44:55:66", vendor_name: "Old Co")
    newer = Lookup.create!(mac: "AA:BB:CC:DD:EE:FF", vendor_name: "New Co")

    get "/lookups"

    assert_response :success
    assert_equal [ newer.mac, older.mac ], JSON.parse(response.body).map { |l| l["mac"] }
  end

  test "GET /lookups only returns the most recent RECENT_LIMIT lookups" do
    (Lookup::RECENT_LIMIT + 5).times do |i|
      Lookup.create!(mac: "00:00:00:00:%02X:%02X" % [ i / 256, i % 256 ], vendor_name: "Vendor #{i}")
    end

    get "/lookups"

    assert_response :success
    assert_equal Lookup::RECENT_LIMIT, JSON.parse(response.body).length
  end

  test "returns JSON error for an unmatched route" do
    post "/lookups"
    assert_response :not_found
    assert JSON.parse(response.body)["error"].present?

    get "/lookups/1"
    assert_response :not_found
    assert JSON.parse(response.body)["error"].present?
  end

  private

  # Simulates another request inserting the same mac between our find_by
  # miss and our create!, by making create! itself perform that insert
  # (via #save!, which isn't overridden) and then raise the same uniqueness
  # error a real race would produce.
  def with_racing_lookup_create
    Lookup.define_singleton_method(:create!) do |mac:, vendor_name:|
      Lookup.new(mac: mac, vendor_name: vendor_name).save!
      raise ActiveRecord::RecordInvalid, Lookup.new
    end
    yield
  ensure
    Lookup.singleton_class.send(:remove_method, :create!)
  end
end
