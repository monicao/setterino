require "test_helper"

describe Setting do
  describe "::store" do
    it "must store a key and a value" do
      Setting.store("admin_email", "admin@gmail.com").must_equal true
    end

    it "should update a value" do
      Setting.store "admin_email", "admin@gmail.com"
      Setting.store "admin_email", "new_admin@gmail.com"
      Setting.count.must_equal 1
      Setting.last.reload.value.must_equal "new_admin@gmail.com"
    end

    it "should not save a setting without a value" do
      proc do
        Setting.store nil, "blah"
      end.must_raise Setting::InvalidKey
    end

    it "must raise a ValueTooLong exception when the value is too long" do
      proc do
        Setting.store("max_connect_retry", "c" * 254)
      end.must_raise Setting::ValueTooLong
    end

    it "must raise a DatabaseError if anything else goes wrong with saving to the database" do
      fake_ar_exception = ActiveRecord::ActiveRecordError.new "Shhhh! I'm hunting wabbits!"
      Setting.any_instance.expects(:save!).raises(fake_ar_exception)
      proc do
        Setting.store("max_connect_retry", 4)
      end.must_raise Setting::DatabaseError, "Shhhh! I'm hunting wabbits!"
    end
  end

  describe "::get" do
    it "should retrieve a value in the original data type" do
      Setting.store "max_connect_retry", 4
      Setting.get("max_connect_retry").must_equal 4
    end

    it "should return nil if the key does not exist" do
      Setting.get("max_connect_retry").must_equal nil
    end

    it "must raise a DatabaseError if anything else goes wrong with reading from the database" do
      fake_ar_exception = ActiveRecord::ActiveRecordError.new "Shhhh! I'm hunting wabbits!"
      Setting.expects(:find_by).raises(fake_ar_exception)
      proc do
        Setting.get("max_connect_retry")
      end.must_raise Setting::DatabaseError, "Shhhh! I'm hunting wabbits!"
    end
  end
end
