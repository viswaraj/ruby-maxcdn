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

Every request can take an optional debug parameter.
```ruby
api.get("/account.json", :debug => true)
# Will output
# Making GET request to https://rws.netdna.com/myalias/account.json
#{... API Returned Stuff ...}
```
