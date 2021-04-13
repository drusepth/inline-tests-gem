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

class MethodsToOnlyExistInSpecialBlock
  def awesome_method(x, y)
    x + y
  end
end

special_block = Proc.new do
  puts awesome_method(5, 2)
end

asserter = MethodsToOnlyExistInSpecialBlock.new
asserter.instance_exec(&special_block)

InlineTests.run!