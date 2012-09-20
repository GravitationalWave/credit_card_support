module CreditCardSupport

  class Luhn
    MAGIC = [7, 3, 1]

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

    def checksum_part
      full_number[-1, 1] if full_number
    end

    def valid?
      parts   = full_number.split(//).reverse

      other   = true
      parts   = parts.collect do |part|
        (other = !other) ? part : part*2
      end

      sum     = parts.join("").split(//).map(&:to_i).inject(:+)
      sum % 10 == 0
    end

    def invalid?
      !valid?
    end

  end

end
