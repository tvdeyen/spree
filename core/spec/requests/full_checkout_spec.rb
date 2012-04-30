require 'spec_helper'

describe "Full Checkout flow", :js => true do
  before do
    shipping_method = Factory(:shipping_method, :zone => Spree::Zone.find_by_name("North America"))
    shipping_method.calculator.set_preference(:amount, 10)

    Factory(:payment_method, :environment => 'test')
    Factory(:product, :name => "RoR Mug")
    Factory(:authorize_net_payment_method, :environment => 'test')
  end

  let!(:address) { Factory(:address, :state => Spree::State.first) }

  context "can go through the whole checkout process" do
    before do
      visit spree.root_path
      click_link "RoR Mug"
      click_button "Add To Cart"
      click_link "Checkout"

      page.should have_content("Billing Address")
      page.should have_content("Shipping Address")

      str_addr = "bill_address"
      select "United States", :from => "order_#{str_addr}_attributes_country_id"
      ['firstname', 'lastname', 'address1', 'city', 'zipcode', 'phone'].each do |field|
        fill_in "order_#{str_addr}_attributes_#{field}", :with => "#{address.send(field)}"
      end
      select "#{address.state.name}", :from => "order_#{str_addr}_attributes_state_id"
      check "order_use_billing"
      click_button "Save and Continue"
      click_button "Save and Continue"
      click_button "Save and Continue"
    end

    it "paying by check" do
      click_button "Save and Continue"
      page.should have_content("Your order has been processed successfully")
    end

    it "paying by card" do
      choose 'Credit Card'
      fill_in "card_number", :with => "4111111111111111"
      fill_in "card_code", :with => "123"
      click_button "Save and Continue"
      page.should have_content("Your order has been processed successfully")
    end
  end
end
