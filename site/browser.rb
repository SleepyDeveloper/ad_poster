module Site
  # home_page.rb
  #
  # A page object for the site HomePage handles login
  #
  # 2016/12/27 Justin Jeffress  
  require 'watir-webdriver'
  module Browser
    extend self

    def browser
      setup_browser
    end

    private

    def setup_browser
      browser = Watir::Browser.new :firefox
      browser.window.resize_to(1400, 900)
      browser
    end
  end
end
