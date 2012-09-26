CreditCardSupport
=================

Intro
-----

* Internationalization and localization support for validations
* At the moment knows AMEX, DinersClub, Discover, Enroute, Maestro, MasterCard, JCB, Solo, VISA (if you need more, create an issue and request for it :)


Basic usage
-----------

```ruby
# for a String object
credit_card_number = "5500005555555559"
credit_card_number.extend(CreditCardSupport::CreditCardNumber)

# or for all the Strings
class String
  include CreditCardSupport::CreditCardNumber
end

# Usage
credit_card_number.luhn?   # true
credit_card_number.issuer  # :visa
credit_card_number.test?   # true
```

For better understanding read the source and RSpec.


Validations support
-------------------

* validates Luhn (http://en.wikipedia.org/wiki/Luhn_algorithm)
* validates issuer
* validates that number is not a test number
* for presence, length etc, please use Rails already existing validators :)

### Define

#### ActiveRecord or Mongoid

```ruby
class CreditCard < ActiveRecord::Base

  attr_accessible :number

  validates :number, presence: true,
                      length: {
                        minimum: 13,
                        maximum: 19
                        },
                      credit_card_number: {
                        allow_testcards: true,
                        allow_issuers: [:visa, :master_card]
                      }

end
```

#### Only ActiveModel

##### Rails 3

```ruby
class CreditCard
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :number, :expiry_year, :expiry_month, :errors

  def initialize(opts={})
    @errors = ActiveModel::Errors.new(self)
    opts.each {|key, value| send("#{key}=", value) }
  end

  validates :number, presence: true,
                      length: {
                        minimum: 13,
                        maximum: 19
                        },
                      credit_card_number: {
                        allow_testcards: true,
                        allow_issuers: [:visa, :master_card]
                      }

end
```

##### Rails 4

```ruby
class CreditCard
  include ActiveModel::Model

  attr_accessor :number, :expiry_year, :expiry_month

  validates :number, presence: true,
                      length: {
                        minimum: 13,
                        maximum: 19
                        },
                      credit_card_number: {
                        allow_testcards: true,
                        allow_issuers: [:visa, :master_card]
                      }

end
```

### Use

After you have defined your CreditCard

```ruby
today      = Date.today
```

```ruby
creditcard = CreditCard.new(number: '4000111111111115')
creditcard.valid?             # true

# in case of allow_testcards is set to false
creditcard.valid?             # false
creditcard.errors             # <ActiveModel::Errors: ... @messages={:number=>["testcards not supported"]}>
```


Problems?
=========

Create an issue or submit a patch.


Inspired by
===========

* https://github.com/tobias/credit_card_validator
* https://github.com/pda/am_credit_card
* http://rubygems.org/gems/creditcard


Author
======

Margus Pärt
