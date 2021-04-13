module Kernel
  METHODS_WITH_INLINE_TESTS     = []

  RUN_TESTS_IN_THIS_ENVIRONMENT = true

  def tested(method_name, _ignored, &inline_test_block)
    return unless RUN_TESTS_IN_THIS_ENVIRONMENT

    # Hoist the method variable outside of the block below so we can access it afterwards
    method = nil

    # The method definition exists in a different scope dependent on whether we're in a class or not.
    if self.class.name === Object.name
      # We're in `main` scope
      method = method(method_name)
      
    elsif self.class.name == Class.name
      # We're in a class -- hunt for that method

      if instance_methods.include?(method_name)
        method = self.instance_method(method_name)

        # Since the method is defined at script startup, it's an UnboundMethod until there's an instance to
        # call it on. Obviously, need an instance to call it from during a test anyway, so we bind one here
        # manually.
        # TODO: this would be a great place to read defaults for some classes and apply attributes/defaults
        #       upon creation
        instance = self.new
        method   = method.bind(instance)

      elsif self.singleton_class.instance_methods.include?(method_name)
        method = self.singleton_class.instance_method(method_name).bind(self)

      end
    end

    # Register the method's tests to be run with InlineTests
    method.inline_tests = inline_test_block
    METHODS_WITH_INLINE_TESTS << method

    method
  end
  def tests; end

  # This is just syntax sugar for decorating methods that are untested / need tests
  def untested(method_name); end

  def assert(some_statement, description = '')
    passed = !!some_statement
    raise InlineTestFailure.new('assert', some_statement, nil, description) unless passed

    passed
  end

  def assert_equal(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] == [rhs]")
    raise InlineTestFailure.new('assert_equal', lhs, rhs, description) unless passed

    passed
  end

  def assert_not_equal(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] != [rhs]")
    raise InlineTestFailure.new('assert_not_equal', lhs, rhs, description) unless passed

    passed
  end

  def assert_less_than(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] < [rhs]")
    raise InlineTestFailure.new('assert_less_than', lhs, rhs, description) unless passed
    
    passed
  end

  def assert_greater_than(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] > [rhs]")
    raise InlineTestFailure.new('assert_greater_than', lhs, rhs, description) unless passed
    
    passed
  end

  def assert_divisible_by(lhs, rhs, description = '')
    passed = !!flexible_assert(lhs, rhs, "[lhs] % [rhs] == 0")
    raise InlineTestFailure.new('assert_divisible_by', lhs, rhs, description) unless passed
    
    passed
  end

  # TODO: assert_positive
  # TODO: assert_negative

  # dirty hacks for global constants :(
  module Infinity; def to_s; Float::INFINITY;     end; end
  module NaN;      def to_s; 0 * Float::INFINITY; end; end

  private

  def flexible_assert(lhs, rhs, assert_logic)
    lhs_values = lhs
    # todo: probably want a custom testresults class instead of hash
    lhs_values = lhs.values if lhs.is_a? Hash
    lhs_values = Array(lhs_values) unless lhs_values.is_a? Array

    rhs_values = rhs
    rhs_values = rhs.values if rhs.is_a? Hash
    rhs_values = Array(rhs_values) unless rhs_values.is_a? Array

    lhs_values.all? do |lhs|
      rhs_values.all? do |rhs|
        generated_source = assert_logic.gsub('[lhs]', lhs.to_s).gsub('[rhs]', rhs.to_s)
        # puts "Debug: Evaluating #{generated_source}"
        eval generated_source
      end
    end
  end
end