require 'active_model'
require 'spec_helper'
require 'credit_card_support/validators/credit_card_number_validator' if Object.const_defined?(:ActiveModel)

class CreditCard
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :number

  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def initialize(opts={})
    opts.each do |k,v|
      send(:"#{k}=", v)
    end
  end

end

class CreditCardTest < CreditCard
  validates :number, presence: true,
                      length: {
                        minimum: 13,
                        maximum: 19
                        },
                      credit_card_number: {
                        allow_testcards: true,
                        allow_issuers: [:visa, :master_card]
                      }
end

class CreditCardProduction < CreditCard
  validates :number, presence: true,
                      length: {
                        minimum: 13,
                        maximum: 19
                        },
                      credit_card_number: {
                        allow_testcards: false,
                        allow_issuers: [:visa, :master_card]
                      }
end


describe ActiveModel::Validations::CreditCardNumberValidator do
  subject { CreditCardTest.new(number: '4012888888881881'.freeze) }

  it "is valid" do
    subject.should be_valid
  end

  describe "#number" do
    it "must exist" do
      subject.number = nil
      subject.should_not be_valid
    end
    it "must be luhn" do
      subject.number = '4012888888881882'
      subject.should_not be_valid
    end
    context "production" do
      subject { CreditCardProduction.new(number: '4485071359608368') }
      context "testnumber" do
        it "is invalid" do
          subject.number = '4012888888881881'
          subject.should be_invalid
        end
      end
      context "valid number" do
        it "is valid" do
          subject.should be_valid
        end
      end
    end
  end
end
