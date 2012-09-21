module CreditCardSupport

  class Luhn

    attr_accessor :full_number

    def initialize(full_number)
      self.full_number = full_number
    end

    def full_number=(full_number)
      @full_number = full_number.gsub(/[^0-9]/, '').to_s
    end

    def number_part
      full_number[0, full_number.length-1] if full_number
    end

    def check_digit_part
      full_number[-1, 1] if full_number
    end

    def valid?
      return false unless full_number and full_number.length > 2
      parts   = full_number.split(//).map(&:to_i)

      double  = parts.length % 2 == 0
      parts   = parts.collect do |part|
        number  = double ? part*2 : part
        double  = !double
        number
      end

      sum     = parts.join("").split(//).map(&:to_i).inject(:+)
      sum % 10 == 0
    end

    def invalid?
      !valid?
    end

  end

end
