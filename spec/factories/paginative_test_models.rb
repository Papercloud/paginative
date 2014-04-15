# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :test_model, :class => 'Paginative::TestModel' do
    sequence(:name) { |n| "#{("a".."zzz").to_a[n]}" }
    latitude 1.5
    longitude 1.5
  end
end
