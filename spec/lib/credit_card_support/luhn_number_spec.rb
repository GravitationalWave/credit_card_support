require 'spec_helper'

describe CreditCardSupport::LuhnNumber do

  VALID_LUHNS = [
                  "5500005555555559",
                  "5555555555555557",
                  "5454545454545454",
                  "5555515555555551",
                  "5405222222222226",
                  "5478050000000007"
                ]
  INVALID_LUHNS = [
                    "5500005555555558",
                    "5555555555555556",
                    "5454545454545453",
                    "5555515555555550",
                    "5405222222222225",
                    "5478050000000006"
                  ]

  describe "#luhn?" do
    context "valid luhn" do
      it "returns true" do
        VALID_LUHNS.each do |number|
          number.extend(described_class)
          number.should be_luhn
        end
      end
    end
    context "invalid luhn" do
      it "returns false" do
        INVALID_LUHNS.each do |number|
          number.extend(described_class)
          number.should_not be_luhn
        end
      end
    end
  end

end
