module Site
  # home_page.rb
  #
  # A page object for site RedactedPage handles posting an ad to site
  #
  # 2016/12/27 Justin Jeffress
  class RedactedPage
    def initialize(browser)
      @browser = browser
      goto_redacted_page if !redacted_page?
    end

    # post an ad to site
    def post_ad(title, post_body, url, address, listing_time)
      @browser.div(:id, 'side-left').div(:class, 'menu').div.a.click
      set_type
      confirm_login_info
      fill_out_event_info title, post_body, url
      fill_out_address address
      set_go_live_date listing_time
      click_done
      confirm_complete
    end

    private

    # sets the type to FR_CATEGORY_HOBBI hobby.
    # At this moment it's not necessary to provide an option to choose a
    # category so I hard coded it.
    def set_type
      @browser.radio(name: '_CID[category]', value: 'FR_CATEGORY_HOBBI').set
      goto_next_page
    end

    # TODO: Priority: LOW confirm that the email address in the matches what
    # we expect to be logged in as.
    def confirm_login_info
      goto_next_page
    end

    # fill out the event info page of the form nothing special.
    # no need to worry about adding options to allow selecting a gender.
    def fill_out_event_info(title, post_body, url)
      @browser.select_list(:name, '_CID[gender]').select_value('FR_GENDER_MALE')

      @browser.input(:name, '_CID[title]').send_keys title
      @browser.textarea(:name, '_CID[comment]').send_keys post_body
      @browser.input(:name, '_CID[url]').send_keys url
      goto_next_page
    end

    # fills out the input fields on the page
    def fill_out_address(address)
      # array represents input fields on the page so we loop through and set the text
      [
        { name: '_CID[addr]', symbol: :address },
        { name: '_CID[city]', symbol: :city},
        { name: '_CID[state]', symbol: :state},
        { name: '_CID[zip]', symbol: :zip},
        { name: '_CID[country]', symbol: :country}
      ].each do | entry_hash |
        # clear each field before inserting otherwise it will append with
        # what was in the post previously.
        @browser.input(:name, entry_hash[:name]).to_subtype.clear
        @browser.input(:name, entry_hash[:name]).send_keys address[entry_hash[:symbol]]
      end
      goto_next_page
    end

    # sets the go live date for the advertisement
    def set_go_live_date(listing_time)
      [
        { id: 'jid_listing_time[ym]', symbol: :year_month },
        { id: 'jid_listing_time[d]', symbol: :day },
        { id: 'jid_listing_time[h]', symbol: :hour },
        { id: 'jid_listing_time[m]', symbol: :minute }
      ].each do | entry |
        @browser.select_list(:id, entry[:id]).select_value(listing_time[entry[:symbol]])
      end
    end

    # completes the form by clicking the 'done' button
    def click_done
      @browser.div(:class, 'complete')
    end

    # advances the form one page forward
    def goto_next_page
      @browser.div(:class, 'next').input(:type, 'submit').click
      sleep 1.0
      @browser.div(:id, 'main').wait_until_present
    end

    # confirms that the form was submitted and returns the url to the new advertisement
    def confirm_complete
      @browser.dl(:class, 'final').wait_until_present
      @browser.dl(:class, 'final').dd.a.href
    end

    # checks to see if the current page is the redacted page
    def redacted_page?
      @browser.url == 'https://site.com/' ? true : false
    end

    # clicks on the redacted page link
    def goto_redacted_page
      @browser.li(:class, 're').a.click
      return redacted_page?
    end
  end
end
