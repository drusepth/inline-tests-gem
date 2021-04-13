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
    inline_tests.call self if inline_tests && inline_tests.respond_to?(:call)
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