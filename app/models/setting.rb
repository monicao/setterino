class Setting < ActiveRecord::Base
  class ValueTooLong  < StandardError; end
  class InvalidKey    < StandardError; end
  class DatabaseError < StandardError; end

  serialize :value, JSON

  MAX_VALUE_LENGTH = 255 # AR imposes this limit on string types. Seems like a good limit for settings.

  validates :key, presence: true, uniqueness: true

  class << self
    def store(key, value)
      raise ValueTooLong if value.to_json.length > MAX_VALUE_LENGTH
      begin
        setting = create_or_update key, value
        invalidate_cache! key
        setting.persisted?
      rescue ActiveRecord::RecordInvalid => e
        raise InvalidKey, e.message
      rescue ActiveRecord::ActiveRecordError => e
        raise DatabaseError, e.message
      end
    end
    alias_method :[]=, :store

    def get(key)
      Rails.cache.fetch "setting/#{key}" do
        find_by(key: key).try(:value)
      end
    rescue ActiveRecord::ActiveRecordError => e
      raise DatabaseError, e.message
    end
    alias_method :[], :get

    private
    def create_or_update(key, value)
      setting = nil
      Setting.transaction do
        setting = find_by(key: key) || new(key: key)
        setting.value = value
        setting.save!
      end
      setting
    end

    def invalidate_cache!(key)
      Rails.cache.delete "setting/#{key}"
    end
  end
end

