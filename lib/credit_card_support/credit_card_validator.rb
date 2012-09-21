raise "ActiveModel not included" unless Object.const_defined?(:ActiveModel)
I18n.load_path << File.dirname(__FILE__) + '/locale/en.yml'

class CreditCardValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    @record          = record

    opts              = options.dup
    opts[:number]     ||= attribute

    number            = record.send(opts[:number]||:number) rescue (raise ":number not defined")
    expiry_year       = record.send(opts[:expiry_year]||:expiry_year) rescue (raise ":expiry_year not defined")
    expiry_month      = record.send(opts[:expiry_month]||:expiry_month) rescue (raise ":expiry_month not defined")
    @allowed_issuers  = opts[:allowed_issuers]
    @allow_testcards  = opts[:allow_testcards]

    @opts             = opts
    @instrument       = CreditCardSupport::Instrument.new(number: number, expiry_year: expiry_year, expiry_month: expiry_month)

    validate_number
  end


  private

  def errors
    @record.errors
  end

  def instrument
    @instrument
  end

  def validate_number
    validate_luhn
    validate_issuer
    validate_testcard
    validate_expiry_year
    validate_expiry_month
    validate_expiration_date rescue false
  end

  def validate_luhn
    errors.add(@opts[:number], t(:luhn_not_valid)) unless @instrument.has_valid_luhn?
  end

  def validate_issuer
    errors.add(@opts[:number], t(:issuer_not_known)) unless @instrument.issuer
    if @allowed_issuers and @instrument.issuer and !@allowed_issuers.map(&:to_sym).include?(@instrument.issuer)
      errors.add(@opts[:number], t(:issuer_not_supported, issuer: @instrument.issuer.to_s.upcase))
    end
  end

  def validate_testcard
    errors.add(@opts[:number], t(:testcard_not_supported)) if !@allow_testcards && @instrument.is_testcard?
  end

  def validate_expiry_year
    errors.add(@opts[:expiry_year], t(:cant_be_blank)) unless @instrument.expiry_year
  end

  def validate_expiry_month
    errors.add(@opts[:expiry_month], t(:cant_be_blank)) unless @instrument.expiry_month
  end

  def validate_expiration_date
    if @instrument.expired?
      errors.add(@opts[:expiry_year], t(:cant_be_expired))
      errors.add(@opts[:expiry_month], t(:cant_be_expired))
    end
  end

  def t(code, *args)
     I18n.t("credit_card_validator.messages.#{code}", *args)
  end

end
