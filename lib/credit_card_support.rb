require 'credit_card_support/luhn_number'
require 'credit_card_support/credit_card_number'

if Object.const_defined?(:ActiveModel)
  require 'credit_card_support/validators/credit_card_number_validator'
else
  puts "CreditCardSupport: ActiveModel validations not loaded"
end
