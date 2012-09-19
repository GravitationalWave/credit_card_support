Why?
====

Because I can!


What?
=====

It is somewhat a ripp-off from
* https://github.com/tobias/credit_card_validator

and also inspired by
* https://github.com/pda/am_credit_card


Basic usage

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
