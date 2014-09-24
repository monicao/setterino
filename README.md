## Rails Setting Model

Sample code that stores application settings in a Rails model called `Setting`. Crafted with <3 for Careguide.

### Usage

```ruby
  # Hash-like syntax
  Setting[:max_connection_retry] = 5
  #=> true

  Setting[:max_connection_retry]
  #=> 5

  # More traditional class-method approach
  Setting.store :max_connection_retry, 5
  #=> true

  Setting.get :max_connection_retry
  #=> 5
```

### Caching

Uses [low level caching](http://edgeguides.rubyonrails.org/caching_with_rails.html#low-level-caching) to avoid hitting the database.

