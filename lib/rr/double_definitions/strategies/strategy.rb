module RR
  module DoubleDefinitions
    module Strategies
      class Strategy
        class << self
          attr_reader :strategy_method_name
          def register(strategy_method_name, *alias_method_names)
            @strategy_method_name = strategy_method_name
            register_self_at_double_definition_create(strategy_method_name)
            DoubleDefinitionCreate.class_eval do
              alias_method_names.each do |alias_method_name|
                alias_method alias_method_name, strategy_method_name
              end
            end
            RR::Adapters::RRMethods.register_strategy_class(self, strategy_method_name)
            DoubleDefinition.register_strategy_class(self, strategy_method_name)
            RR::Adapters::RRMethods.class_eval do
              alias_method_names.each do |alias_method_name|
                alias_method alias_method_name, strategy_method_name
              end
            end
          end

          def register_self_at_double_definition_create(strategy_method_name)
          end
        end

        attr_reader :double_definition_create, :definition, :method_name, :args, :handler
        include Space::Reader

        def initialize(double_definition_create)
          @double_definition_create = double_definition_create
        end
        
        def call(definition, method_name, args, handler)
          @definition, @method_name, @args, @handler = definition, method_name, args, handler
          do_call
        end

        def name
          self.class.strategy_method_name
        end

        def verify_subject(subject)
        end  

        protected
        def do_call
          raise NotImplementedError
        end

        def permissive_argument
          if args.empty?
            definition.with_any_args
          else
            definition.with(*args)
          end
        end

        def reimplementation
          definition.returns(&handler)
        end

        def subject
          definition.subject
        end
      end
    end
  end
end