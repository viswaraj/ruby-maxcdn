# NetDNA REST Web Services Ruby Client

## Installation
`gem install netdnarws`

## Usage
```ruby
require 'netdnarws'

api = NetDNARWS::NetDNA.new("myalias", "consumer_key", "consumer_secret")

api.get("/account.json")
```

## Methods
It has support for `GET`, `POST`, `PUT` and `DELETE` OAuth 1.0a signed requests.

```ruby
# To create a new Pull Zone
api.post("/zones/pull.json", {'name' => 'test_zone', 'url' => 'http://my-test-site.com'})

# To update an existing zone
api.put("/zones/pull.json/1234", {'name' => 'i_didnt_like_test'})

# To delete a zone
api.delete("/zones/pull.json/1234")
```
