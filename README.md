CreditCardSupport
=================

Basic usage without Rails
-------------------------

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


Basic usage with ActiveModel (if you are using Rails, you are using ActiveModel)
--------------------------------------------------------------------------------

```ruby
class CreditCard < Your::BaseClass
  include CreditCardSupport::For::ActiveModel

  attr_accessor :number, :issuer, :expire_date, :holder_name
  attr_accessable :number, :issuer,

  validates :
end
```


Inspired by
===========

* https://github.com/tobias/credit_card_validator
* https://github.com/pda/am_credit_card


Author
======

Margus Pärt
