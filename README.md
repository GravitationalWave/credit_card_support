CreditCardSupport
=================

Basic usage
-----------

```ruby
credit_card = CreditCardSupport.Instrument.new(
  number: '4222222222222',
  expire_year: 13,
  expire_month: 11,
  holder_name: 'A B'         # optional!
  verification: '1234'       # optional!
)

credit_card.expired?          # returns false
credit_card.expire_date       # Date (last day of the month for expire month)
credit_card.issuer            # VISA
credit_card.is_testcard?     # true
```

For better understanding read the source and RSpec.


Validations support
-------------------

### Define

#### ActiveRecord or Mongoid

```ruby
class CreditCard < ActiveRecord::Base

  attr_accessable :number, :expiry_year, :expiry_month

  validates :number, credit_card: {
                                    # credit_card_config: :local_method_name
                                    expiry_year: :expiry_year,
                                    expiry_month: :expiry_month,
                                    allowed_issuers: [:visa, :mastercard],
                                    allow_testcards: !Rails.env.production?
                                  }

end
```

#### Only ActiveModel

```ruby
class CreditCard
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :number, :expiry_year, :expiry_month
  attr_accessable :number, :expiry_year, :expiry_month

  validates :number, credit_card: {
                                    # credit_card_config: :local_method_name
                                    expiry_year: :expiry_year,
                                    expiry_month: :expiry_month,
                                    allowed_issuers: [:visa, :mastercard],
                                    allow_testcards: !Rails.env.production?
                                  }

end
```

### Use

After you have defined your CreditCard

```ruby
today      = Date.today
```

```ruby
# RAILS_ENV == 'test'
creditcard = CreditCard.new(number: '4000111111111115', expiry_year: today.year, expiry_month: today.month)
creditcard.valid? # True

# RAILS_ENV == 'production'
creditcard = CreditCard.new(number: '4000111111111115', expiry_year: today.year, expiry_month: today.month)
creditcard.valid? # False
creditcard.errors # {number: ["is a test number"]}

# RAILS_ENV == 'test'
creditcard = CreditCard.new(number: '3566003566003566', expiry_year: today.year-1, expiry_month: today.month)
creditcard.valid? # False
creditcard.errors # {number: ["is a JCB card number and is not supported", expiry_year: ["is in the past"], expiry_month: ["is in the past"]]}

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
