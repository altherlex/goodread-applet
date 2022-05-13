# RSpec.describe "Mytest", :type => :request do
#   describe "check smth" do
#     it "should be eq" do
#       expect(3).to   eq(3)
#     end
#   end
# end

describe "the signin process", type: :feature do
  it "signs me in" do
    visit "https://www.goodreads.com/ap/signin?language=en_US&openid.assoc_handle=amzn_goodreads_web_na&openid.claimed_id=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.identity=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0%2Fidentifier_select&openid.mode=checkid_setup&openid.ns=http%3A%2F%2Fspecs.openid.net%2Fauth%2F2.0&openid.pape.max_auth_age=0&openid.return_to=https%3A%2F%2Fwww.goodreads.com%2Fap-handler%2Fsign-in&siteState=6bf54030f4183ac435f450aeb36d8ff3"
    within("#session") do
      fill_in 'Email', with: 'para.alves@gmail.com'
        fill_in 'Password', with: 'lbvlbv0008'
    end
    click_button 'Sign in'
    expect(page).to have_content 'by Joaquim Nabuco'
  end
end