# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_model, :class => 'TestModel' do
    sequence(:name) { |n| "#{("a".."zzz").to_a[n]}" }
    latitude -37.01
    longitude 144
  end
end
