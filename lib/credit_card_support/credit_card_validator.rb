I18n.load_path << File.dirname(__FILE__) + '/locale/en.yml'

class CreditCardValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    @record          = record

    opts              = options.dup
    opts[:number]     ||= attribute

    @number_name        = opts[:number] || :number
    @expiry_year_name   = opts[:expiry_year] || :expiry_year
    @expiry_month_name  = opts[:expiry_month] || :expiry_month

    @number           = record.send(@number_name)
    @expiry_year      = record.send(@expiry_year_name)
    @expiry_month      = record.send(@expiry_month_name)
    @allowed_issuers  = opts[:allowed_issuers]
    @allow_testcards  = opts[:allow_testcards]

    @instrument       = CreditCardSupport::Instrument.new(number: @number, expiry_year: @expiry_year, expiry_month: @expiry_month)

    validate_number
    validate_expiration
  end


  private

  def errors
    @record.errors
  end

  def instrument
    @instrument
  end

  def validate_number
    validate_number_luhn
    validate_number_issuer
    validate_number_testcard
  end

  def validate_expiration
    validate_expiry_year
    validate_expiry_month
    validate_expiration_date rescue nil
  end

  def validate_number_luhn
    errors.add(@number_name, t(:luhn_not_valid)) unless @instrument.has_valid_luhn?
  end

  def validate_number_issuer
    errors.add(@number_name, t(:issuer_not_known)) unless @instrument.issuer
    if @allowed_issuers and @instrument.issuer and !@allowed_issuers.map(&:to_sym).include?(@instrument.issuer)
      errors.add(@number_name, t(:issuer_not_supported, issuer: @instrument.issuer.to_s.upcase))
    end
  end

  def validate_number_testcard
    errors.add(@number_name, t(:testcard_not_supported)) if !@allow_testcards && @instrument.is_testcard?
  end

  def validate_expiry_year
    errors.add(@expiry_year_name, t(:cant_be_blank)) unless @instrument.expiry_year
  end

  def validate_expiry_month
    errors.add(@expiry_month_name, t(:cant_be_blank)) unless @instrument.expiry_month
  end

  def validate_expiration_date
    if @instrument.is_expired?
      errors.add(@expiry_year_name, t(:cant_be_expired))
      errors.add(@expiry_month_name, t(:cant_be_expired))
    end
    if @instrument.expiration_date > Date.new(Date.today.year+10)
      errors.add(@expiry_year_name, t(:cant_be_so_far_in_the_future))
    end
  end

  def t(code, *args)
     I18n.t("credit_card_validator.messages.#{code}", *args)
  end

end
