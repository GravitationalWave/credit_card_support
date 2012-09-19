require 'spec_helper'
require 'date'

describe CreditCardSupport::Instrument do
  let(:today) { Date.today }
  subject { described_class.new(number: 4222222222222, expire_year: "#{today.year+1}", expire_month: "12", holder_name: 'A B', verification: '1234') }

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
    it "determines issuer for the number" do
      described_class.determine_issuer("4000111111111115").should == :visa
      described_class.determine_issuer("40001111111111156").should == nil
    end
  end

  describe ".determine_is_testcard?" do
    it "determines if number is testnumber" do
      described_class.determine_is_testcard?("4000111111111115").should be_true
      described_class.determine_is_testcard?("4000111111111116").should be_false
    end
  end

  describe "#initialize" do
    it "creates a new Instrument" do
      subject.should be_a(described_class)
    end
    it "sets values" do
      subject.number.should == "4222222222222"
      subject.expire_year.should == today.year+1
      subject.expire_month.should == 12
      subject.holder_name.should == 'A B'
      subject.verification.should == '1234'
    end
  end

  describe "#expire_date" do
    it "returns last day of the month when expiring" do
      subject.expire_date.should == Date.new(today.year+1, 12, 31)
    end
  end

  describe "#expired?" do
    it "returns false if not expired" do
      subject.expired?.should be_false
    end
    it "returns true if expired" do
      subject.expire_year = today.year
      subject.expire_month = today.month-1
      subject.expired?.should be_true
    end
  end

  describe "#is_testcard?" do
    it "returns false if not a testcard" do
      subject.number = 4222222222223
      subject.is_testcard?.should be_false
    end
    it "returns true if a testcard" do
      subject.number = 4222222222222
      subject.is_testcard?.should be_true
    end
  end


end
