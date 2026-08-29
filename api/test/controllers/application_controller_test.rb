require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  test "returns 500 with the standard JSON error shape for an unhandled exception" do
    singleton = Lookup.singleton_class
    original_recent = singleton.instance_method(:recent)
    singleton.define_method(:recent) { raise "boom" }

    get "/lookups"

    assert_response :internal_server_error
    assert_equal "unexpected server error", JSON.parse(response.body)["error"]
  ensure
    singleton.define_method(:recent, original_recent)
  end
end
