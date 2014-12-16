describe "signin", :type => :feature, :js => true do

  before :all do
    @current_user = create(:user)
  end

  after :all do
    @current_user.destroy
  end

  it "logs in user" do

    # sign in
    visit new_user_session_path

    # fill out log in form
    fill_in 'user_email', with: @current_user.email
    fill_in 'user_password', with: @current_user.password
    find("#new_user input[type='submit']").click

    # execute jQuery selector to check page/H1 contents:
    result = page.evaluate_script("$(\"h1#profiles_test\").text()")
    expect(result).to eq "Select Similarity function"

  end

end