class Setting < ActiveRecord::Base
  class ValueTooLong  < StandardError; end
  class InvalidKey    < StandardError; end
  class DatabaseError < StandardError; end

  serialize :value, JSON

  MAX_VALUE_LENGTH = 255 # AR imposes this limit on string types. Seems like a good limit for settings.

  validates :key, presence: true, uniqueness: true

  def self.store(key, value)
    raise ValueTooLong if value.to_json.length > MAX_VALUE_LENGTH
    begin
      setting = self.create_or_update key, value
      self.invalidate_cache! key
      setting.persisted?
    rescue ActiveRecord::RecordInvalid => e
      raise InvalidKey, e.message
    rescue ActiveRecord::ActiveRecordError => e
      raise DatabaseError, e.message
    end
  end

  def self.get(key)
    Rails.cache.fetch "setting/#{key}" do
      self.find_by(key: key).try(:value)
    end
  rescue ActiveRecord::ActiveRecordError => e
    raise DatabaseError, e.message
  end

  private
  def self.create_or_update(key, value)
    setting = nil
    Setting.transaction do
      setting = self.find_by(key: key) || self.new(key: key)
      setting.value = value
      setting.save!
    end
    setting
  end

  def self.invalidate_cache!(key)
    Rails.cache.delete "setting/#{key}"
  end

end

