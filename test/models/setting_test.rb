require "test_helper"

describe Setting do
  describe "::store" do
    it "must store a key and a value" do
      Setting.store("admin_email", "admin@gmail.com").must_equal true
    end

    it "must raise a ValueTooLong exception when the value is too long" do
      proc do
        Setting.store("max_connect_retry", "c" * 254)
      end.must_raise Setting::ValueTooLong
    end

    it "must raise a DatabaseError if anything else goes wrong with saving to the database" do
      fake_ar_exception = ActiveRecord::ActiveRecordError.new "Shhhh! I'm hunting wabbits!"
      Setting.expects(:create!).raises(fake_ar_exception)
      proc do
        Setting.store("max_connect_retry", 4)
      end.must_raise Setting::DatabaseError, "Shhhh! I'm hunting wabbits!"
    end

  end
end
