module CreditCardSupport

  # Usage:
  #
  # @example Get Luhn check code
  #   Luhn.new("12345").checksum   # returns 9
  #
  # @example See if Luhn check code is valid
  #   Luhn.is_valid?("123458")      # returns false
  #   Luhn.is_valid?("123459")      # returns true

  class Luhn
    MAGIC = [7, 3, 1]

    attr_accessor :number

    def self.is_valid? code
      code = code.to_s
      return false unless code.length > 0
      self.new(code[0, code.length-1]).checksum.to_s == code[-1, 1]
    end

    def initialize code
      @number = code
    end

    def checksum
      parts       = number.split //

      i = 0
      multiplied  = parts.map(&:to_i).collect do |part|
        m = part * MAGIC[i]
        i = (i==2) ? 0 : i.succ
        m
      end

      summarized  = multiplied.inject(:+)
      summarized % 10
    end

  end

end
