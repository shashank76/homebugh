require "spec_helper"

feature "Cash Flows" do
  background do
    @user = create(:user)
    login @user

    @from_account = create(:from_account, user: @user, name: "From Account")
    @to_account = create(:to_account, user: @user, name: "To Account")
  end

  context "cash_flows_path" do
    background { visit cash_flows_path }

    scenario "get list of cash flows" do
      page.should have_content("List of cash flows")
    end

    scenario "have link to Move funds" do
      page.has_link?("Move funds").should be_true
    end
  end

  context "create" do
    scenario "when successul create" do
      create_flow
      expect(page).to have_content "Funds was successfully moved."
      expect(page).to have_content "From Account → To Account"
      expect(page).to have_content "15.00"
      expect(current_path).to eq cash_flows_path
    end
  end

  scenario "should destroy(rollback) flow" do
    create_flow

    page.should have_content("From Account → To Account")
    page.should have_content("15.00")
    click_link "Rollback"
    page.should_not have_content("From Account → To Account")
    page.should_not have_content("15.00")
  end

  scenario "should raise validation on create" do
    visit new_cash_flow_path
    select "From Account", from: "cash_flow_from_account_id"
    select "From Account", from: "cash_flow_to_account_id"
    fill_in "cash_flow_amount", with: "0"

    click_button "cash_flow_submit"
    page.should have_content("You cannot move funds to same account")
    page.should have_content("Cannot be less than 0.01")
  end
end

def create_flow
  visit new_cash_flow_path
  select "From Account", from: "cash_flow_from_account_id"
  select "To Account", from: "cash_flow_to_account_id"
  fill_in "cash_flow_amount", with: 15
  click_button "cash_flow_submit"
end
