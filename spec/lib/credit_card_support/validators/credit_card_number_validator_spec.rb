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
  validates :number,
  credit_card_number: true,
  credit_card_support: {
    allow_testcards: true,
    allow_issuers: [:visa, :master_card]
  }
end

class CreditCardWithCustomMessage < CreditCard
  validates :number,
  credit_card_number: { message: 'Luhn fail!' },
  credit_card_support: {
    allow_testcards: true,
    allow_issuers: [:visa, :master_card],
    message: "Not supported!"
  }
end

class CreditCardWithCustomLambdaMessage < CreditCard
  validates :number,
  credit_card_number: { message: ->(trans_string, context){ "Luhn fail! #{trans_string} #{context[:value]}" } },
  credit_card_support: {
    allow_testcards: false,
    allow_issuers: [:visa, :master_card],
    message: ->(trans_string, context){ "Not supported! #{trans_string} #{context[:value]}" }
  }
end

class CreditCardProduction < CreditCard
  validates :number,
  credit_card_number: true,
  credit_card_support: {
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
      subject.errors[:number].first.should == 'is not valid'
    end

    it "must reject unsupported cards" do
      subject.number = '3528000000000007'
      subject.should_not be_valid
      subject.errors[:number].first.should == 'jcb not supported'
    end

    it "must support random whitespace around card numbers" do
      subject.number = ' 4012 8888 8 8 8 8 1881    '
      subject.should be_valid
    end

    context "with custom card support messages" do
      subject { CreditCardWithCustomMessage.new(number: '3528000000000007') }
      it "has a custom message" do
        subject.valid?
        subject.errors[:number].first.should == 'Not supported!'
      end
    end

    context "with custom luhn calculation failure messages" do
      subject { CreditCardWithCustomMessage.new(number: '4111111111111112') }
      it "has a custom message" do
        subject.valid?
        subject.errors[:number].first.should == 'Luhn fail!'
      end
    end

    context "with custom card support messages in lambda form" do
      subject { CreditCardWithCustomLambdaMessage.new(number: '3528000000000007') }
      it "has a custom message" do
        subject.valid?
        subject.errors[:number].first.should == 'Not supported! activemodel.errors.models.credit_card_with_custom_lambda_message.attributes.number.testcard_not_supported 3528000000000007'
      end
    end

    context "with custom test card support messages in lambda form" do
      subject { CreditCardWithCustomLambdaMessage.new(number: '4111111111111111') }
      it "has a custom message" do
        subject.valid?
        subject.errors[:number].first.should == 'Not supported! activemodel.errors.models.credit_card_with_custom_lambda_message.attributes.number.testcard_not_supported 4111111111111111'
      end
    end

    context "with custom luhn calculation failure messages in lambda form" do
      subject { CreditCardWithCustomLambdaMessage.new(number: '4111111111111112') }
      it "has a custom message" do
        subject.valid?
        subject.errors[:number].first.should == 'Luhn fail! activemodel.errors.models.credit_card_with_custom_lambda_message.attributes.number.luhn_not_valid 4111111111111112'
      end
    end

    context "production" do
      subject { CreditCardProduction.new(number: '4485071359608368') }
      context "testnumber" do
        it "is invalid" do
          subject.number = '4012888888881881'
          subject.should be_invalid
          subject.errors[:number].first.should == 'testcards not supported'
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
