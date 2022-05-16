require 'puppeteer-ruby'
require 'clipboard'
require 'dotenv/load'
require 'active_support/core_ext/string'

# Only works for text copied from Books reader by Apple
applebook_clipboard = Clipboard.paste
unless applebook_clipboard.include?("Excerpt") && applebook_clipboard.include?("”")
  exit(true)
end

Puppeteer.launch(headless: false, slow_mo:10, args: ['--no-sandbox', '--disable-dev-shm-usage', '--window-size=1280,1200']) do |browser|
  page = browser.new_page
  signin_url = "https://www.goodreads.com/ap/signin?language=en_US&openid.assoc_handle=amzn_goodreads_web_na&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.goodreads.com%2Fap-handler%2Fsign-in&siteState=6bf54030f4183ac435f450aeb36d8ff3"
  page.goto(signin_url, wait_until: 'domcontentloaded')

  page.query_selector("#ap_email").focus
  page.keyboard.type_text(ENV['GODREADS_USER'])

  page.query_selector("#ap_password").focus
  page.keyboard.type_text(ENV['GODREADS_PASSWORD'])

  page.wait_for_navigation do
    page.query_selector("#signInSubmit").click
  end

  # Add quote
  page = browser.new_page
  page.goto("https://www.goodreads.com/quotes/new", wait_until: 'domcontentloaded')

  pbpaste_list = applebook_clipboard.split('”')
  quote = pbpaste_list[0][1..]
  author = pbpaste_list[1].split(/\n/)[4]
  book = pbpaste_list[1].split(/\n/)[3]

  # --Type quote
  page.query_selector("#quote_body").focus
  page.keyboard.type_text(quote)

  # --Type author
  page.query_selector("#quote_author_name").focus
  page.keyboard.type_text(author)

  # --Type tag
  page.query_selector("#quote_tags_string").focus
  page.keyboard.type_text(book.parameterize)

  page.wait_for_timeout(3000) # 3s

  # page.wait_for_navigation do
  #   # form = page.query_selector("form.quoteForm")
  #   # form.query_selector("input.gr-button").click
  # end
  # page.click('input[type=submit]')
  page.evaluate(<<~JAVASCRIPT)
    () => { document.querySelector('input[type=submit]').click(); }
  JAVASCRIPT

  begin
    # page.wait_for_timeout(30000) 

    # Click Recapcha
    page.wait_for_selector("iframe")
    elementHandle = page.query_selector("#g-recaptcha > iframe")
    iframe = elementHandle.content_frame()
    
    # now iframe is like "page", and to click in the button you can do this
    iframe.click("div.recaptcha-checkbox-border")  

    page.wait_for_timeout(30000) # 30s
  rescue 
    page.wait_for_timeout(30000) 
    
    # Clipboard.copy(applebook_clipboard)
    page.screenshot(path: "goodreads-sign-in-page.png")
  end
end
