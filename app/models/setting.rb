class Setting < ActiveRecord::Base
  class ValueTooLong  < StandardError; end
  class DatabaseError < StandardError; end

  serialize :value, JSON

  MAX_VALUE_LENGTH = 255 # AR imposes this limit on string types. Seems like a good limit for settings.

  def self.store(key, value)
    raise ValueTooLong if value.to_json.length > MAX_VALUE_LENGTH
    self.create!(key: key, value: value).persisted?
  rescue ActiveRecord::ActiveRecordError => e
    raise DatabaseError, e.message
  end

end
