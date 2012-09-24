require 'spec_helper'
require 'date'

describe CreditCardSupport::CreditCardNumber do

  describe "#testcard?" do
    context "a testcard" do
      it "returns true" do
        number = "378282246310005"
        number.extend(described_class)
        number.should be_testcard
      end
    end
    context "not a testcard" do
      it "returns false" do
        number = "4916119578780242"
        number.extend(described_class)
        number.should_not be_testcard
      end
    end
  end

  describe "#issuer" do
    described_class::TESTCARDS.each do |issuer, numbers|
      context "#{issuer}" do
        it "is recognized" do
          numbers.each do |number|
            number.extend(described_class)
            number.issuer.should == issuer
          end
        end
      end
    end
  end

end
