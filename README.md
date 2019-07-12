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

Parse auth hash:

``` ruby
profile = SocialProfile.get(auth_hash)
profile.picture_url   # http://profile.ak.fbcdn.net/h..._4963049_s.jpg
profile.gender        # 0 - unknown, 1 - female, 2 - male
profile.profile_url   # http://www.facebook.com/develop.rails
profile.provider      # facebook
```

Post photo to social album. If album dosn't exists, it's create new one:

``` ruby
user = SocialProfile::Person.get(:facebook, uid, access_token)

user.share_photo!(album_id, filepath, {
  :album => {:name => "Site pictures"}, 
  :photo => {:message => "Cool photo"}
})

```

For parsing instagram followers via browser you should to set `ENV['INSTAGRAM_USERNAME']`, `ENV['INSTAGRAM_PASSWORD']`,
`ENV['GMAIL_USERNAME']` and `ENV['GMAIL_PASSWORD']` with your instagram and gmail credentials (email which linked to instagram account).
Instagram credentials needed for instagram authentication, and gmail credentials for cases
when instagram requires to fill in verification code from email during the login.
And then You can to fetch followers from the instagram account.

```ruby
user = SocialProfile::Person.get(:instagram_parser, uid, access_token, browser_parsing: true)
user.friends(count: 100)
```

`count` is 200 by default.

Firefox browser is used by default. To set chrome `export SOCIAL_PROFILE_BROWSER='chrome'`

By default instagram followers are parsing without browser.
To parse followers you need to set env variable with path to file with authorized cookies `export INSTAGRAM_COOKIES_PATH=/path/to/cookies`
You can to get cookies string from the browser from Developer Tools Network tab.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Copyright (c) 2013 Fodojo, released under the MIT license
