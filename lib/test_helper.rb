# The methods in this class are available whenever you're in a tests do ... end block.
class TestHelper
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
end