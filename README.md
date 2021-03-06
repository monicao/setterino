## Rails Setting Model

Sample code that stores application settings in a Rails model called `Setting`. Crafted with <3 for Careguide.

### Usage

```ruby
#
# Hash-like syntax
#

Setting[:max_connection_retry] = 5
#=> true

Setting[:max_connection_retry]
#=> 5

#
# ... or class methods
#

Setting.store :max_connection_retry, 5
#=> true

Setting.get :max_connection_retry
#=> 5

Setting.get :key_that_doesnt_exist
#=> nil

#
# Error Handling
#

Setting[nil] = "something"
# raises Setting::InvalidKey: Validation failed: Key can't be blank
```

### Caching

Uses [low level caching](http://edgeguides.rubyonrails.org/caching_with_rails.html#low-level-caching) to avoid hitting the database.

