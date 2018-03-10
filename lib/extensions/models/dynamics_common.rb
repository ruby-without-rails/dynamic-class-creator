module Extensions
  module DynamicsCommon
    Dynamics.constants.each {|klass_sym|
      klass = Kernel.const_get('Dynamics::?'.gsub('?', klass_sym.to_s))
      klass.class_eval {
        # Do everything(whatever) you want here.
        puts "Extending #{klass.name}"

        class << self
          def say_hello
            'TWO BECK!'
          end

          def are_you_crazy?
            true
          end
        end

      }
    }
  end
end