# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dummy_model do
    name "MyString"
    address "MyString"
    latitude -37.001
    longitude 144
  end
end
