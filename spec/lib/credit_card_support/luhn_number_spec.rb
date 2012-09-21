require 'spec_helper'

describe CreditCardSupport::LuhnNumber do

  subject { described_class.new("4485071359608368") }

  describe "#initialize" do
    it "sets full_number" do
      described_class.any_instance.should_receive(:full_number=).with('123')
      described_class.new('123')
    end
  end

  describe "#full_number" do
    it "returns only number part of set value" do
      subject.full_number = '123 abc-'
      subject.full_number.should == '123'
    end
  end

  describe "#number_part" do
    it "returns number part of full_number" do
      subject.number_part.should == "448507135960836"
    end
  end

  describe "#check_digit_part" do
    it "returns number part of full_number" do
      subject.check_digit_part.should == "8"
    end
  end

  describe "#valid?" do
    it "returns if luhn algorytm % 10 is true" do
      subject.should be_valid
    end
  end

  describe "#valid?" do
    context "valid luhn" do
      it "returns true" do
        described_class.new("5500005555555559").should be_valid
        described_class.new("5555555555555557").should be_valid
        described_class.new("5454545454545454").should be_valid
        described_class.new("5555515555555551").should be_valid
        described_class.new("5405222222222226").should be_valid
        described_class.new("5478050000000007").should be_valid
      end
    end
    context "invalid luhn" do
      it "returns false" do
        described_class.new("5500005555555558").should be_invalid
        described_class.new("5555555555555556").should be_invalid
        described_class.new("5454545454545453").should be_invalid
        described_class.new("5555515555555550").should be_invalid
        described_class.new("5405222222222225").should be_invalid
        described_class.new("5478050000000006").should be_invalid
      end
    end
  end

end
