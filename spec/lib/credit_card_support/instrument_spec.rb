require 'spec_helper'
require 'date'

describe CreditCardSupport::Instrument do
  let(:today) { Date.today }
  subject { described_class.new(number: 4222222222222, expiry_year: "#{today.year}", expiry_month: "12", holder_name: 'A B', verification: '1234') }

  describe ".numbers" do
    it "returns hash containing of issuer: number_regexp" do
      described_class.numbers.should be_a(Hash)
    end
  end

  describe ".testcard_numbers" do
    it "returns hash containing of testcard numbers" do
      described_class.testcard_numbers.should be_a(Hash)
    end
  end

  describe ".determine_issuer" do
    described_class.testcard_numbers.each do |issuer, numbers|
      context "#{issuer}" do
        it "knows the numbers" do
          numbers.each do |number|
            described_class.determine_issuer(number).should == issuer
          end
        end
      end
    end
  end

  describe ".is_testcard?" do
    it "determines if number is testnumber" do
      described_class.is_testcard?("4000111111111115").should be_true
      described_class.is_testcard?("4000111111111116").should be_false
    end
  end

  describe "#initialize" do
    it "supports a hash" do
      instrument = described_class.new(number: "123")
      instrument.number.should == "123"
    end
    it "supports a block" do
      instrument = described_class.new do |instrument_object|
        instrument_object.number = "123"
      end
      instrument.number.should == "123"
    end
  end

  describe "#number" do
    it "returns number as a string" do
      subject.number = "1-2-3-412345"
      subject.number.should == "123412345"
    end
  end

  describe "#expiry_year" do
    it "returns expiry year as NNNN integer" do
      subject.expiry_year = "#{today.year-2000}"
      subject.expiry_year.should == today.year
    end
  end

  describe "#expiry_month" do
    it "returns expiry month as NN integer" do
      subject.expiry_month = "#{today.month}"
      subject.expiry_month.should == today.month
    end
  end

  describe "#expiration_date" do
    it "returns last day of the month when expiring" do
      subject.expiration_date.should == Date.new(today.year, 12, 31)
    end
  end

  describe "#expired?" do
    context "not expired" do
      it "returns false" do
        subject.expired?.should be_false
      end
    end
    context "expired" do
      it "returns true" do
        subject.expiry_year = today.year
        subject.expiry_month = today.month-1
        subject.expired?.should be_true
      end
    end
  end

  describe "#is_testcard?" do
    context "not a testcard" do
      it "returns false" do
        subject.number = 4222222222223
        subject.is_testcard?.should be_false
      end
    end
    context "a testcard" do
      it "returns true" do
        subject.number = 4222222222222
        subject.is_testcard?.should be_true
      end
    end
  end

  describe "has_valid_luhn?" do
    context "valid luhn" do
      it "returns true" do
        subject.number = 4222222222222
        subject.is_testcard?.should be_true
      end
    end
    context "invalid luhn" do
      it "returns false" do
        subject.number = 4222222222223
        subject.is_testcard?.should be_false
      end
    end
  end


end
