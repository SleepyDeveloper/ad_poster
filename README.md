AdPoster
========

**NOTE:** This code has been sanitized. I removed all references to the real
site that this works with in order to prevent site from being overrun with
robots.

AdPoster automates posting an ad to site. I post ads on a weekly basis to site
where only the date changes. There's no RESTful api so I wrote this robot to
automate posting my ad. Once posted, the URL to the ad is emailed to the account
that posted it via MailGun. Why site doesn't provide this feature I don't know.

This script is set to run once a week via `crontab` the `--day|-d` option
specifies the `next day of the week` that this ad corresponds to (it's time
limited). The next date is computed and then substituted into the title of the
ad which is defined in a .json config file.

At some point I plan to refactor Site and MailGunHelper into gems complete with
gemspecs and defined dependencies so you wont have to install requirements
manually.

- [Requirements](#requirements)
- [Configuration](#configuration)
- [Script Invocation](#invocation)

---

Requirements
------------

### [Watir web-driver](https://rubygems.org/gems/watir-webdriver)
```
gem install watir-webdriver # used to simulate the browser
```
### [mailgun](https://rubygems.org/gems/mailgun)
```
gem install mailgun # used to send the email (requires an account and registered domain)
```
### [trollop](https://rubygems.org/gems/trollop/versions/2.1.2)
```
gem install trollop # an awesome command line options gem.
```
### [dotenv](https://rubygems.org/gems/dotenv)
```
gem install dotenv # loads environment vars
```

Configuration
------------

AdPoster requires three configuration files, two are **dotenv** shims one for
**mailgun** and one for **site**, the other is a **.json** file that contains
the ad content. The path for the **mailgun shim** is set in an environment
variable **ENV['MAILGUN_ENV']**, and is loaded via `Dotenv.load ENV['MAILGUN_ENV']`
in **post_to_site.rb**. Likewise, the shim for **site** is also defined in an
environment variable, however it is loaded based on the value of **account**
set in the **.json** config file. This allows for posting ads with a different
set of credentials. It is loaded via `Dotenv.load ENV[post_data[:account].upcase]`
which means you need to make sure you have an environment variable with the same
name as the account for example:

.bash_profile
```
export FOO=/Some/Path/to/the/dotenv_file/.foo
```
foo.json
```
{
  "account": "foo",
  ...
}
```

### Sample .json config file

The data is pretty much always the same, except the month and date. The script
will replace `#{month}` and `#{date}` with date determined by the command line
option `--day|-d` (See [invocation](#invocation) for option details).

```
{
  "account": "foo",
   "title": "required: #{month}#{date} the month and date fields will be replaced with actual data",
   "body": "The Body",
   "url":  "Optional: URL to include in the ad",
   "address": {
     "address": "555 Fake Street",
     "city": "Some City",
     "state": "CA",
     "zip": "90210",
     "country": "United States"
   }
}
```

### Sample Mailgun shim
```
MAILGUN_API_KEY=your_mailgun_key
MAILGUN_DOMAIN=your_mailgun_domain
```

### Sample Account/Site shim
```
SITE_USERNAME=your_username
SITE_PASSWORD=your_password
```

Invocation
-----------
```
ruby post_to_site.rb --day 0-6 --config path_to_file
```

### Options

* day, d - The day of the week that this time sensitive ad runs until.
* config, c - A .json config file containing all the data for the ad including
which account to post it under.

### Example Invocation
```
ruby post_to_site.rb -d 3 -c ~/ad_configs/wednesday_ad.json
```

The above will compute the date for next Wednesday, (-d 3), if run on Tuesday
will return tomorrow's (Wednesday's) date, if run on Thursday, will return next
Wednesday's date. The .json file is loaded, and the browser will log into
`account` and the **#{month}** and **#{date}** will be replaced by next
Wednesday and the ad is posted to site.
