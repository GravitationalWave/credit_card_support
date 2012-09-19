module CreditCardSupport
  module Support
    module Rails

      class ExampleInstrument
        extend  ActiveModel::Naming
        extend  ActiveModel::Translation
        include ActiveModel::Validations
        include ActiveModel::Conversion
      end

    end
  end
end
