raise "ActiveModel not included" unless Object.const_defined?(:ActiveModel)

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
    errors.add(@opts[:number], "not valid") unless @instrument.has_valid_luhn?
  end

  def validate_issuer
    errors.add(@opts[:number], "not known issuer") unless @instrument.issuer
    if @allowed_issuers and @instrument.issuer
      errors.add(@opts[:number], "issuer #{@instrument.issuer.uppercase} is not supported") unless @allowed_issuers.map(&:to_sym).include?(@instrument.issuer)
    end
  end

  def validate_testcard
    errors.add(@opts[:number], "is a testcard") if !@allow_testcards && @instrument.is_testcard?
  end

  def validate_expiry_year
    errors.add(@opts[:expiry_year], "is missing") unless @instrument.expiry_year
  end

  def validate_expiry_month
    errors.add(@opts[:expiry_month], "is missing") unless @instrument.expiry_month
  end

  def validate_expiration_date
    if @instrument.expired?
      errors.add(@opts[:expiry_year], "is in the past")
      errors.add(@opts[:expiry_month], "is in the past")
    end
  end

end
