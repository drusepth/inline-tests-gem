require_relative './lib/kernel_extensions'
require_relative './lib/method_extensions'
require_relative './lib/inline_tests'
require_relative './lib/test_helper'
require_relative './lib/inline_test_failure'

tested def integer_division(x, y)
  return Infinity if y.zero?
  x.to_i / y.to_i
end,
tests do
  assert 6 / 3 == 2, 'it works'
end

tested def add x, y
  x + y
end,
tests do
  assert_greater_than fuzz[0, (1..1_000)], 0, 'adding anything to zero should be greater than zero'
  assert_greater_than fuzz[(1..1_000), 0], 0, 'addition should be commutative'
  assert_equal        fuzz[0, 0], 0,          '0 + 0 = 0'
  assert_equal        fuzz[1, 1], 2,          '1 + 1 = 2'
  assert_not_equal    fuzz[1, 2], 2,          '1 + 2 != 2'
end

tested def subtract x, y
  x - y
end,
tests do
  assert_equal fuzz[555, 0], 555,                                   '555 - 0 = 555'
  assert_greater_than fuzz[10_000, (0..9_999)], 0,                  'subtracting n from m where n < m should be greater than 0'
  assert_equal fuzz[Float::INFINITY, (0..10_000)], Float::INFINITY, 'subtracting anything from infinity should still be infinity'
end

tested def multiply x, y
  x * y
end,
tests do
  assert_divisible_by fuzz[3, 5], 5,                                '3 * 5 should be divisible by 5'
  assert_divisible_by fuzz[3, 5], 3,                                '3 * 5 should be divisible by 3'
  assert_divisible_by fuzz[(1..10_000), 5], 5,                      'multiplying anything by 5 should be divisible by 5'
  assert_equal fuzz[(1..10_000), Float::INFINITY], Float::INFINITY, 'multiplying anything by infinity should be infinity'
  assert_equal fuzz[0, Float::INFINITY], 0 * Float::INFINITY,       'multiplying 0 by infinity should be NaN'
end

tested def divide x, y
  return Float::INFINITY if y.zero?
  x.to_f / y
end,
tests do
  assert_equal fuzz[0, 3],  0,                         'can use fuzz[x, y] to call function shorthand'
  assert_equal fuzz.(0, 3), 0,                         '0 / 3 = 0'
  assert_equal fuzz.(6, 3), 2,                         '6 / 3 = 2'
  assert_equal fuzz.(3, 0), Float::INFINITY,           'dividing by zero results in infinity'
  assert_equal fuzz[(0..10_000), 0], Float::INFINITY,  'anything / 0 == infinity'
  assert_equal fuzz[0, (1..10_000)], 0,                '0 / anything == 0'
end


InlineTests.run!