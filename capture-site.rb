require 'puppeteer-ruby'
require 'clipboard'

Puppeteer.launch(headless: false, args: ['--no-sandbox', '--disable-dev-shm-usage']) do |browser|
  page = browser.new_page
  signin_url = "https://www.goodreads.com/ap/signin?language=en_US&openid.assoc_handle=amzn_goodreads_web_na&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.goodreads.com%2Fap-handler%2Fsign-in&siteState=6bf54030f4183ac435f450aeb36d8ff3"
  page.goto(signin_url, wait_until: 'domcontentloaded')

  page.query_selector("#ap_email").click
  page.keyboard.type_text("user@gmail.com")

  page.query_selector("#ap_password").click
  page.keyboard.type_text("*************")

  page.wait_for_navigation do
    page.query_selector("#signInSubmit").click
  end

  # Add quote
  page = browser.new_page
  page.goto("https://www.goodreads.com/quotes/new", wait_until: 'domcontentloaded')

  # applebook_clipboard = `pbpaste`
  applebook_clipboard = Clipboard.paste

  pbpaste_list = applebook_clipboard.split('”')
  quote = pbpaste_list[0][1..]
  author = pbpaste_list[1].split(/\n/)[4]
  book = pbpaste_list[1].split(/\n/)[3]

  # --Type quote
  page.query_selector("#quote_body").focus
  page.keyboard.type_text(quote)
  # Clipboard.copy(quote)
  # page.evaluate(<<~JAVASCRIPT)
  #   () => { document.execCommand('cut') }
  # JAVASCRIPT
  # page.keyboard.down('MetaLeft');
  # page.keyboard.press('v');
  # page.keyboard.up('MetaLeft');

  # --Type author
  page.query_selector("#quote_author_name").focus
  page.keyboard.type_text(author)
  # Clipboard.copy(author)
  # page.keyboard.down('Control');
  # page.keyboard.press('v');
  # page.keyboard.up('Control');

  # --Type tag
  page.query_selector("#quote_tags_string").focus
  page.keyboard.type_text(book)
  # Clipboard.copy(book)
  # page.keyboard.down('Control');
  # page.keyboard.press('v');
  # page.keyboard.up('Control');

  Clipboard.copy(applebook_clipboard)
  page.screenshot(path: "goodreads-sign-in-page.png")
end
