require 'trollop'
require 'dotenv'
require 'json'
require 'date'

# post_to_site.rb
#
# This script uses Site to post the ad specified in a json config file
# to site.com Below is a sample advertisement json
# {
#   "account": "my_account",
#    "title": "required: #{month}#{date} the month and date fields will be replaced with actual data",
#    "body": "The Body",
#    "url":  "Optional: URL to include in the ad",
#    "address": {
#      "address": "555 Fake Street",
#      "city": "Some City",
#      "state": "CA",
#      "zip": "90210",
#      "country": "United States"
#    }
# }
#
# 2016/12/29 Justin Jeffress

# adding the site folder to the load path
$LOAD_PATH << File.join(File.dirname(__FILE__), 'site')

$LOAD_PATH << File.join(File.dirname(__FILE__), 'mailgun_helper')

require 'site.rb'
require 'mailgun_helper.rb'

opts = Trollop::options do
  opt :day, "Day of week 0-6 where 0 is Sunday and 6 is Saturday", type: :integer
  opt :config, "A JSON File that contains the post information as well as the account name to post as", type: :string
end

Trollop::die :day, "You must specify the day of the week" if opts.day.nil?
Trollop::die :config, "You must provide a config file" if opts.config.nil? || opts.config.empty?

# http://mariojvargas.com/2009/04/25/finding-the-next-date-for-day-of-week/
# Determines how many days until the next desired day of the week.
# S M T W T F S
# 0 1 2 3 4 5 6
# For example, Today is Thursday and we want to know how many days unitl next
# Tuesday passing 2 for Tuesday to days_to_add will return how many days
def days_to_add(desired)
  # c is current day of week, d is desired next day of week
  # f( c, d ) = g( c, d ) mod 7, g( c, d ) > 7
  #           = g( c, d ), g( c, d ) <= 7
  # g( c, d ) = [7 - (c - d)] = 7 - c + d
  #   where 0 <= c < 7 and 0 <= d < 7
  n = (7 - DateTime.now.wday + desired);
  (n > 7) ? n % 7 : n
end

# computes the next date for the week
def get_next_date_for_next_weekday(week_day)
  DateTime.now + days_to_add(week_day)
end

next_meetup = get_next_date_for_next_weekday(opts.day)

# loading the ad config data
post_data = JSON.parse(File.read(opts.config), symbolize_names: true)

# load the config shim for mailgun
Dotenv.load ENV['MAILGUN_ENV']

# load shim based on the account specified in the
# json config file (For each account you want to post as, you will need to
# provide an environment variable which is a path to its shim.)
Dotenv.load ENV[post_data[:account].upcase]

# replace the #{month} and #{date} placeholders with acutal values
title = post_data[:title].gsub(/#\{month\}/, next_meetup.month.to_s)
        .gsub(/#\{day\}/, next_meetup.day.to_s)

# reinsert the \n character into the JSON
body = post_data[:body].gsub(/\\n/, "\n")
today = DateTime.now

# we want our listing to go live immediately
listing_time = {
  year_month: today.strftime("%Y/%-m"),
  day: today.strftime("%-d"),
  hour: '0',
  minute: '00'
}

# create the browser
browser = Site::Browser.browser

# got to the homepage and login (HomePage logs automatically if !not_logged_in?)
home_page = Site::HomePage.new browser

# navigate to the redacted page which is where we want to post from
redacted_page = Site::RedactedPage.new browser

# post the advertisement
post_url = redacted_page.post_ad title, body, post_data[:url], post_data[:address], listing_time

MailgunHelper.send_message to: ENV['SITE_USERNAME'],
  subject: "New Ad posted to Site for #{next_meetup.strftime("%Y/%m/%d")}",
  html: post_url
