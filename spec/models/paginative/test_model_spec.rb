require_relative '../../spec_helper'

describe TestModel do

  before :each do
    TestModel.class_eval do
      include Paginative::ModelExtension

      reverse_geocoded_by :latitude, :longitude
      after_validation :reverse_geocode          # auto-fetch coordinates
    end
  end

  def create_models
    @model1 = FactoryGirl.create(:test_model, address: "Lorem", created_at: Time.now.ago(2.days))
    @model2 = FactoryGirl.create(:test_model, address: "Ipsum", created_at: Time.now.ago(1.days))
    @model3 = FactoryGirl.create(:test_model, address: "New York", created_at: Time.now)
    @model4 = FactoryGirl.create(:test_model, address: "BroadWay", created_at: (Time.now + 1.day))
    @model5 = FactoryGirl.create(:test_model, address: "Island St", created_at: (Time.now + 2.days))
  end

  describe "by passed field" do
    it "defaults to 25 results" do
      models = FactoryGirl.create_list(:test_model, 30)
      TestModel.with_field_from("created_at", (Time.now.yesterday)).count.should eq 25
    end

    it "returns results subsequent rows after given value on field" do
      10.times do |count|
        FactoryGirl.create(:test_model, created_at: Time.now.ago(count.days))
      end

      TestModel.with_field_from("created_at", (Time.now.ago(5.days))).count.should eq 5
    end

    it "doesn't return values less than the passed in value" do
      create_models

      TestModel.with_field_from("created_at", @model3.created_at).should eq [@model4, @model5]
    end

    it "works on INT values" do
      create_models

      TestModel.with_field_from("id", @model3.id).should match_array [@model4, @model5]
    end

    it "escapes single quotes in the passed in field" do
      models = FactoryGirl.create_list(:test_model, 2)

      TestModel.with_field_from("name", "krystal's farm")
    end
  end

  context "by name" do

    it "is valid" do
      model = FactoryGirl.create(:test_model)

      expect(model).to be_valid
    end

    it "limits the results" do
      models = FactoryGirl.create_list(:test_model, 30)

      expect(TestModel.with_name_from("", 25).length).to eq 25
    end

    it "defaults to 25 results" do
      models = FactoryGirl.create_list(:test_model, 30)

      expect(TestModel.with_name_from("").length).to eq 25
    end

    it "starts from the name that is passed in" do
      # This takes advantage of the [n] counter in the factories
      model1 = FactoryGirl.create(:test_model)
      model2 = FactoryGirl.create(:test_model)
      expect(TestModel.with_name_from(model1.name, 1).first).to eq model2
    end
  end

  context "By distance" do

    it "limits the results" do
      models = FactoryGirl.create_list(:test_model, 30)

      expect(TestModel.by_distance_from(-38, 144, 0, 10).length).to eq 10
    end

    it "defaults to 25 results" do
      models = FactoryGirl.create_list(:test_model, 30)

      expect(TestModel.by_distance_from(-37, 144, 0).length).to eq 25
    end

    it "defaults to 0 distance" do
      model = FactoryGirl.create(:test_model, latitude: -37.01, longitude: 144)

      expect(TestModel.by_distance_from(-37, 144).first).to eq model
    end

    it "only returns objects further away than the passed in distance" do
      close_model = FactoryGirl.create(:test_model, latitude: -37, longitude: 144)
      far_away_model = FactoryGirl.create(:test_model, latitude: 0, longitude: 0)

      expect(TestModel.by_distance_from(-37, 144, 100).length).to eq 1
      expect(TestModel.by_distance_from(-37, 144, 100).first).to eq far_away_model

    end
  end

  context "Sorting" do
    before :each do
      @first = FactoryGirl.create(:test_model, name: "ab", latitude: -37.5, longitude: 144)
      @second = FactoryGirl.create(:test_model, name: "ba", latitude: -38, longitude: 144.5)
    end

    it "defaults to ascending by name" do

      expect(TestModel.with_name_from("a")).to eq [@first, @second]
    end

    it "can be set to descending on name" do
      expect(TestModel.with_name_from("z", 25, "desc")).to eq [@second, @first]
    end

    it "can be set to descending on custom field" do
      expect(TestModel.with_field_from("id", @second.id+1, 25, "desc")).to eq [@second, @first]
    end

    it "always sorts distance by ascending" do
      expect(TestModel.by_distance_from(-37,144,0,2)).to eq [@first, @second]
    end
  end

  context "Multiple Columns" do
    before do
      @first = FactoryGirl.create(:test_model, name: 'abc', address: 'abc', latitude: 140, longitude: 0)
      @second = FactoryGirl.create(:test_model, name: 'abc', address: 'bcd', latitude: 150, longitude: 12)
      @third = FactoryGirl.create(:test_model, name: 'abc', address: 'cde', latitude: 150, longitude: 15)
      @fourth = FactoryGirl.create(:test_model, name: 'abc', address: 'def', latitude: 160, longitude: 2)
    end

    it 'can be paginated on the secondary column (strings)' do
      expect(TestModel.with_field_from(["name", "address"], ["abc", "bcd"])).to eq [@third, @fourth]
    end

    it 'can be paginated by a secondary column (integers)' do
      expect(TestModel.with_field_from(["latitude", "longitude"], [150, 12])).to eq [@third, @fourth]
    end
  end
end
