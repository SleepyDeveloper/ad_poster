module Site
  # home_page.rb
  #
  # A page object for the site HomePage handles login
  #
  # 2016/12/27 Justin Jeffress
  class HomePage
    def initialize(browser)
      @browser = browser

      @browser.goto "https://site.com/"

      login if !logged_in?
    end

    private

    def login
      result = false

      @browser.li(:class, 'login').a.wait_until_present
      if @browser.li(:class, 'login').a.exists?

        @browser.li(:class, 'login').a.click
        @browser.input(:name, "_CID[email]").wait_until_present
        @browser.input(:name, "_CID[email]").send_keys ENV['SITE_USERNAME']
        @browser.input(:name, "_CID[pwd]").send_keys ENV['SITE_PASSWORD']

        @browser.div(:class, 'button-login').input(:type, 'submit').click
        @browser.li(:class, 'logout').wait_until_present

        result = logged_in?
      end

      result
    end

    def logged_in?
      if @browser.li(:class, 'logout').present?
        true
      else
        false
      end
    end

  end
end
