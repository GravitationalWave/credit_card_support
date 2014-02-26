I18n.load_path << File.dirname(__FILE__) + '/../locale/en.yml'

module ActiveModel
  module Validations

    class CreditCardValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        @record     = record
        @attribute  = attribute
        @value      = "#{value}"

        @value.extend(CreditCardSupport::CreditCardNumber)

        validate_internal
      end

      def t(code, *args)
         I18n.t("credit_card_support.validators.number.messages.#{code}", *args)
      end
    end

    class CreditCardSupportValidator < CreditCardValidator
      def validate_internal
        validates_testcard &&
        validates_issuer_allowed
      end

      def validates_testcard
        if !options[:allow_testcards] && @value.testcard?
          @record.errors.add(
            @attribute,
            :testcard_not_supported,
            options.merge(message: options[:message] || t(:testcard_not_supported))
          )
          false
        else
          true
        end
      end

      def validates_issuer_allowed
        if options[:allow_issuers] && !options[:allow_issuers].include?(@value.issuer)
          @record.errors.add(
            @attribute,
            :issuer_not_supported,
            options.merge(message: options[:message] || t(:issuer_not_supported, issuer: @value.issuer)).merge(issuer: @value.issuer)
          )
          false
        else
          true
        end
      end
    end

    class CreditCardNumberValidator < CreditCardValidator
      def validate_internal
        if !@value.luhn?
          @record.errors.add(
            @attribute,
            :luhn_not_valid,
            options.merge(message: options[:message] || t(:luhn_not_valid))
          )
          false
        else
          true
        end
      end
    end
  end
end
