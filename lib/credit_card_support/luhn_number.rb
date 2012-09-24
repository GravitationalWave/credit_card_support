module CreditCardSupport
  module LuhnNumber

    def luhn?
      full_number = to_s.gsub(/[^0-9]/, '')
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

  end
end
