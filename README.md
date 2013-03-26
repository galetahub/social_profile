# SocialProfile

Wrapper for Omniauth profile hash https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema.

## Installation

Add this line to your application's Gemfile:

    gem 'social_profile'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install social_profile

## Usage

``` ruby
profile = SocialProfile.get(auth_hash)
profile.picture_url   # http://profile.ak.fbcdn.net/h..._4963049_s.jpg
profile.gender        # 0 - unknown, 1 - female, 2 - male
profile.profile_url   # http://www.facebook.com/develop.rails
profile.provider      # facebook
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
