require 'spec_helper'

describe "Full Checkout flow" do
  before do
    shipping_method = Factory(:shipping_method, :zone => Spree::Zone.find_by_name("North America"))
    shipping_method.calculator.set_preference(:amount, 10)

    Factory(:payment_method, :environment => 'test')
    Factory(:product, :name => "RoR Mug")
  end

  let!(:address) { Factory(:address, :state => Spree::State.first) }

  it "can go through the whole checkout process", :js => true do
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
    page.should have_content("Your order has been processed successfully")
  end
end
