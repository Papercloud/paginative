require_relative '../../spec_helper'

module Paginative
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
        models = FactoryGirl.create_list(:test_model, 30)

        expect(TestModel.with_name_from("e", 1).first.name).to eq "e"
      end


    end
  end
end
