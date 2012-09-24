I18n.load_path << File.dirname(__FILE__) + '/../locale/en.yml'

class CreditCardNumberValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    @record     = record
    @attribute  = attribute
    @value      = value

    @value.extend(CreditCardSupport::CreditCardNumber)

    validates_luhn &&
    validates_testcard &&
    validates_issuer_allowed
  end

  def validates_luhn
    if !@value.luhn?
      @record.errors.add(@attribute, t(:luhn_not_valid))
      false
    else
      true
    end
  end

  def validates_testcard
    if !options[:allow_testcards] && @value.testcard?
      @record.errors.add(@attribute, t(:testcard_not_supported))
      false
    else
      true
    end
  end

  def validates_issuer_allowed
    if options[:allow_issuers] && !options[:allow_issuers].include?(@value.issuer)
      @record.errors.add(@attribute, t(:issuer_not_supported, issuer: @value.issuer))
      false
    else
      true
    end
  end

  def t(code, *args)
     I18n.t("credit_card_support.validators.number.messages.#{code}", *args)
  end

end
