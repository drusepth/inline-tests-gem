# Inline Tests

This gem defines a method of storing your tests as part of the method they're testing.

## Syntax

To add inline tests to a method, simply prefix the method's `def` with `tested` and then add a `tests` block. Each
`assert` can take an optional description to make your output a little nicer.

For example, say you have the following method:
```ruby
def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
end
```

This is what that method could look like with inline tests:
```ruby
tested def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
end,
tests do
  assert integer_division(6, 3) == 2, "divides correctly"
  assert integer_division(5, 3) == 1, "uses integer division"
  assert integer_division(0, 3) == 0, "0 / anything = 0"
  assert integer_division(3, 0) == Float::INFINITY
end
```

You can also flag methods that need tests but don't have them yet with the `untested` prefix. These methods are
listed at the end of the test suite and made easily-greppable for anyone itchin' to write more tests.
```ruby
untested def integer_division(x, y)
  return Float::INFINITY if y.zero?
  x.to_i / y.to_i
end
```

## Fuzzy testing

This library also supports fuzzy testing. To use it, define a tests block variable (e.g. `this` below) and
pass a _range_ for any parameter using square brackets (`[` `]`) instead of parentheses. Square brackets can also 
be used with non-range values. Every combination in every range will be tested; the condition must be true for every
permutation in order for the test to pass.

For example,
```ruby
tested def add x, y
  x + y
end,
tests do |this|
  assert_greater_than this[0, (1..1_000)], 0, 'adding anything to zero should be greater than zero'
  assert_equal        this[0, 0],          0, '0 + 0 = 0'
end
```

```ruby
tested def multiply x, y
  x * y
end,
tests do |this|
  assert_greater_than this[(-100..-1), (-100..-1)], 0, 'multiplying any two negatives should yield a positive'
end
```

## Example output

In order to run the test suite, all you need to do is call `InlineTests.run!` from anywhere.

```
$ ruby 07_lib_usage.rb 
Starting inline test suite:
  main::add - PASSED (0.000000271 seconds)
  main::integer_division - PASSED (0.000000239 seconds)
  main::multiply - PASSED (0.000000292 seconds)
  main::divide - PASSED (0.000000196 seconds)
4 inline tests ran in 0.000049601 seconds.
  4 PASSED
  0 FAILS
```

Example from Ruby on Rails:
```
$ rails c
Running via Spring preloader in process 9112
Loading development environment (Rails 6.1.0)
irb(main):001:0> InlineTests.run!
Starting inline test suite:
  Analysis::Readability::AutomatedReadabilityIndexService::self.formula - FAILED (0.000279689 seconds)
    FAILED:
      test_type: assert_equal
      lhs: -8
      rhs: 5
1 inline tests ran in 0.000353155 seconds.
  0 PASSED
  1 FAILS

1 methods still need tests:
  Analysis::Readability::AutomatedReadabilityIndexService#baseline
    app/services/analysis/readability/automated_readability_index_service.rb:37
```