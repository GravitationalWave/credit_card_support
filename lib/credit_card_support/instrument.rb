module CreditCardSupport

  # Usage:
  #
  # credit_card = CreditCardSupport.Instrument.new(
  #    number: '4222222222222',
  #    expiry_year: 13,
  #    expiry_month: 11,
  #    holder_name: 'A B'
  #    verification: '1234'       # optional!
  #    )
  #
  # credit_card.expired?          # returns false
  # credit_card.expiration_date   # Date (last day of the month for expiry month)
  # credit_card.issuer            # VISA
  # credit_card.is_testcard?      # true


  class Instrument

    NUMBERS = {
      amex: /^3[47][0-9]{13}$/,
      diners_club: /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/,
      discover: /^6(?:011|5[0-9]{2})[0-9]{12}$/,
      enroute: /^2(014|149)\d{11}$/,
      maestro: /(^6759[0-9]{2}([0-9]{10})$)|(^6759[0-9]{2}([0-9]{12})$)|(^6759[0-9]{2}([0-9]{13})$)/,
      master_card: /^5[1-5][0-9]{14}$/,
      jcb: /^35[0-9]{14}$/,
      solo: /^6(3(34[5-9][0-9])|767[0-9]{2})\d{10}(\d{2,3})?$/,
      visa: /^4[0-9]{12}(?:[0-9]{3})?$/
    }.freeze

    TESTCARD_NUMBERS = {
      amex: [
        '378282246310005',
        '371449635398431',
        '378734493671000',
        '343434343434343',
        '371144371144376',
        '341134113411347'
        ],
      diners_club: [
        '30569309025904',
        '38520000023237',
        '36438936438936'
        ],
      discover: [
        '6011000990139424',
        '6011111111111117',
        '6011016011016011',
        '6011000000000004',
        '6011000995500000',
        '6500000000000002'
        ],
      master_card: [
        '5555555555554444',
        '5105105105105100',
        '5500005555555559',
        '5555555555555557',
        '5454545454545454',
        '5555515555555551',
        '5405222222222226',
        '5478050000000007',
        '5111005111051128',
        '5112345112345114'
        ],
      visa: [
        '4111111111111111',
        '4012888888881881',
        '4222222222222',
        '4005519200000004',
        '4009348888881881',
        '4012000033330026',
        '4012000077777777',
        '4217651111111119',
        '4500600000000061',
        '4000111111111115'
        ],
      jcb: [
        '3566003566003566',
        '3528000000000007'
      ]
    }.freeze

    def self.numbers
      self::NUMBERS
    end

    def self.testcard_numbers
      self::TESTCARD_NUMBERS
    end

    def self.determine_issuer(number)
      numbers.each do |issuer, issuer_regexp|
        return issuer if number.match(issuer_regexp)
      end
      nil
    end

    def self.is_testcard?(number)
      testcard_numbers.values.flatten.include?(number)
    end

    def self.has_valid_luhn?(number)
      CreditCardSupport::Luhn.is_valid?(number)
    end

    attr_accessor   :number,
                    :expiry_year,
                    :expiry_month,
                    :holder_name,
                    :verification

    attr_reader :issuer

    def initialize(opts={}, &block)
      self.number       = opts[:number]
      self.expiry_year  = opts[:expiry_year]
      self.expiry_month = opts[:expiry_month]
      self.holder_name  = opts[:holder_name]
      self.verification = opts[:verification]

      block.call(self) if block
    end

    def number=(number)
      @number           = number.to_s.gsub(/[^0-9]/, '')
      @issuer           = self.class.determine_issuer(self.number)
      @is_testcard      = self.class.is_testcard?(self.number)
      @has_valid_luhn   = self.class.has_valid_luhn?(self.number)
    end

    def expiry_year=(expiry_year)
      @expiry_year = expiry_year.to_i
    end

    def expiry_month=(expiry_month)
      @expiry_month = expiry_month.to_i
    end

    def expiry_year
      (@expiry_year < 1900 ? 2000 + @expiry_year : @expiry_year) if @expiry_year
    end

    def expiration_date
      Date.new(expiry_year, expiry_month, -1)
    end

    def expired?
      expiration_date < Date.today
    end

    def is_testcard?
      @is_testcard
    end

    def has_valid_luhn?
      @has_valid_luhn
    end

  end
end
