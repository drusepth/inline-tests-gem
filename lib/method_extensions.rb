class Method
  attr_accessor :inline_tests

  # Expose a shorthand for .call
  def [](*parameters)
    homogenized_parameters = homogenized_list_of_arrays(parameters)

    permutation_lookup = {}

    all_range_permutations = permutations_of_list_of_ranges(homogenized_parameters)
    all_range_permutations.each do |parameter_permutation|
      permutation_lookup[parameter_permutation] = call(*parameter_permutation)
    end

    should_reduce_results = permutation_lookup.values.uniq.count == 1
    if should_reduce_results
      permutation_lookup.values.first
    else
      permutation_lookup
    end
  end

  def run_inline_tests
    # TODO: this is probably a good place to manage per-test state, reset DB if needed, etc

    # Gem users should be able to use assert(), assert_equal(), etc in their test blocks, but
    # I don't want to pollute the global namespace, so we instantiate a TestHelper (which contains
    # all of those methods) and run each block of inline texts within that TestHelper's context,
    # meaning they can use assert(true) in their test blocks anywhere without having to litter
    # Kernel with global methods OR require people to do something like TestHelper::assert(true).
    testhelper = TestHelper.new
    testhelper.instance_exec(&inline_tests) if inline_tests && inline_tests.respond_to?(:call)
  end

  private

  def homogenized_list_of_arrays(heterogenous_list)
    heterogenous_list.map { |param| Array(param) }
  end

  def permutations_of_list_of_ranges(list_of_ranges)
    receiver, *method_arguments = list_of_ranges
    receiver.product(*method_arguments)
  end
end