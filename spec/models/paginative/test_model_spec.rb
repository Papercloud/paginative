require_relative '../../spec_helper'

describe TestModel do

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
end
