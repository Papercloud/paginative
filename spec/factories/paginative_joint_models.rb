# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :joint_model, class: 'JointModel' do
    sequence(:name) { |n| "#{("a".."zzz").to_a[n]}" }
  end
end
