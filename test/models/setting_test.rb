require "test_helper"

describe Setting do

  before :each do
    Rails.cache.clear
  end
  
  describe "::store" do
    it "must store a key and a value" do
      Setting[:admin_email] = "admin2@gmail.com"
      Setting[:admin_email].must_equal "admin2@gmail.com"

      Setting.store("admin_email", "admin@gmail.com").must_equal true
    end

    it "should accept symbols for the setting keys" do
      Setting.store :max_connect_retry, 4
      Setting.get("max_connect_retry").must_equal 4
    end

    it "should update a value" do
      Setting.store "admin_email", "admin@gmail.com"
      Setting.store "admin_email", "new_admin@gmail.com"
      Setting.get("admin_email").must_equal "new_admin@gmail.com"
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
    it "should retrieve a value using the badass [] syntax" do
      Setting.store "max_connect_retry", 4
      Setting[:max_connect_retry].must_equal 4
    end

    it "should retrieve a value in the original data type" do
      Setting.store "max_connect_retry", 4
      Setting.get("max_connect_retry").must_equal 4
    end

    it "should accept symbols for the setting keys" do
      Setting.store "max_connect_retry", 4
      Setting.get(:max_connect_retry).must_equal 4
    end

    it "should return nil if the key does not exist" do
      Setting.get("max_connect_retry").must_equal nil
    end

    it "should retrieve values from the cache" do
      Setting.store "max_connect_retry", 4
      Setting.expects(:find_by).once
      Setting.get "max_connect_retry"
      Setting.expects(:find_by).never
      Setting.get "max_connect_retry"
    end

    it "should invalidate cache when values are updated" do
      Setting.store "max_connect_retry", 4
      Setting.get "max_connect_retry"
      Setting.store "max_connect_retry", 5
      Setting.get("max_connect_retry").must_equal 5
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
