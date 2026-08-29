require "test_helper"

class LookupTest < ActiveSupport::TestCase
  test "normalize_mac strips separators and upcases hex digits" do
    assert_equal "AA:BB:CC:DD:EE:FF", Lookup.normalize_mac("aa-bb-cc-dd-ee-ff")
  end

  test "normalize_mac leaves an already-normalized mac unchanged" do
    assert_equal "AA:BB:CC:DD:EE:FF", Lookup.normalize_mac("AA:BB:CC:DD:EE:FF")
  end

  test "normalize_mac returns the upcased input unchanged when hex digit count is wrong" do
    assert_equal "AA:BB:CC", Lookup.normalize_mac("aa:bb:cc")
  end

  test "is valid with a well-formed mac and ip" do
    lookup = Lookup.new(mac: "AA:BB:CC:DD:EE:FF", ip: "192.168.1.24", vendor_name: "Example Vendor")

    assert lookup.valid?
  end

  test "normalizes the mac before validating" do
    lookup = Lookup.new(mac: "aa-bb-cc-dd-ee-ff", ip: "192.168.1.24")

    lookup.valid?

    assert_equal "AA:BB:CC:DD:EE:FF", lookup.mac
  end

  test "is invalid without a mac" do
    lookup = Lookup.new(mac: nil, ip: "192.168.1.24")

    assert_not lookup.valid?
    assert_includes lookup.errors[:mac], "can't be blank"
  end

  test "is invalid with a mac that has the wrong number of octets" do
    lookup = Lookup.new(mac: "AA:BB:CC:DD:EE", ip: "192.168.1.24")

    assert_not lookup.valid?
    assert_includes lookup.errors[:mac], "is invalid"
  end

  test "is invalid without an ip" do
    lookup = Lookup.new(mac: "AA:BB:CC:DD:EE:FF", ip: nil)

    assert_not lookup.valid?
    assert_includes lookup.errors[:ip], "can't be blank"
  end

  test "is invalid with a malformed ip" do
    lookup = Lookup.new(mac: "AA:BB:CC:DD:EE:FF", ip: "not-an-ip")

    assert_not lookup.valid?
    assert_includes lookup.errors[:ip], "is invalid"
  end

  test "is invalid with a duplicate mac even in different input casing/separators" do
    Lookup.create!(mac: "AA:BB:CC:DD:EE:FF", ip: "192.168.1.24", vendor_name: "Example Vendor")
    duplicate = Lookup.new(mac: "aa-bb-cc-dd-ee-ff", ip: "192.168.1.25")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:mac], "has already been taken"
  end

  test "found? is true when vendor_name is present" do
    lookup = Lookup.new(vendor_name: "Example Vendor")

    assert lookup.found?
  end

  test "found? is false when vendor_name is nil" do
    lookup = Lookup.new(vendor_name: nil)

    assert_not lookup.found?
  end
end
