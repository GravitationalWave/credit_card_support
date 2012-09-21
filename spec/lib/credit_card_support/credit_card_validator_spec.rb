require 'spec_helper'
require 'active_model'
require 'credit_card_support/credit_card_validator'


class CreditCard
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :number, :expiry_year, :expiry_month

  def initialize(opts={})
    @errors = ActiveModel::Errors.new(self)
    opts.each do |k,v|
      send(:"#{k}=", v)
    end
  end

end

class CreditCardTest < CreditCard
  validates :number, credit_card: {
                              expiry_year: :expiry_year,
                              expiry_month: :expiry_month,
                              allowed_issuers: [:visa, :mastercard],
                              allow_testcards: true
                            }
end

class CreditCardProduction < CreditCard
  validates :number, credit_card: {
                              expiry_year: :expiry_year,
                              expiry_month: :expiry_month,
                              allowed_issuers: [:visa, :mastercard],
                              allow_testcards: false
                            }
end



describe CreditCardValidator do
  let(:today) { Date.today }

  describe "validatable" do

    subject { CreditCardTest.new(number: '4012888888881881', expiry_year: today.year, expiry_month: today.month) }

    it "is valid" do
      subject.should be_valid
    end

    describe "#number" do
      it "must exist" do
        subject.number = nil
        subject.should_not be_valid
      end
      it "must be luhn" do
        subject.number = '4000111111111116'
        subject.should_not be_valid
      end
      context "production" do
        subject { CreditCardProduction.new(number: '4485071359608368', expiry_year: today.year, expiry_month: today.month) }
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

    describe "#expiry_year" do
      it "must exist" do
        subject.expiry_year = nil
        subject.should_not be_valid
      end
      context "in the future" do
        it "is valid" do
          subject.expiry_year = today.year + 1
          subject.should be_valid
        end
      end
      context "in the past" do
        it "is invalid" do
          subject.expiry_year = today.year - 1
          subject.should be_invalid
        end
      end
    end

    describe "#expiry_month" do
      it "must exist" do
        subject.expiry_month = nil
        subject.should_not be_valid
      end
      context "in the future" do
        it "is valid" do
          subject.expiry_month = today.month + 1
          subject.should be_valid
        end
      end
      context "in the past" do
        it "is invalid" do
          subject.expiry_month = today.month - 1
          subject.should be_invalid
        end
      end
    end

  end

end

