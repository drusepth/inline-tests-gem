require_relative './kernel_extensions'
require_relative './method_extensions'

require_relative './inline_test_failure'

class InlineTests
  def self.run!
    test_passes = 0
    test_fails  = 0

    # If we're a gem in a library like Rails that loads models on demand,
    # we need to make sure all the models are loaded before running any tests,
    # because it's the loading of the models that registers each method's tests.
    begin
      Rails.application.eager_load!
    rescue
      # TODO: handle/display any Railsy errors here
    end

    puts "Starting inline test suite:"
    all_tests_start_time = Time.now
    METHODS_WITH_INLINE_TESTS.each do |method|
      # Kernel.class_variable_set(:@@method_being_tested, method)
      
      method_signature = if method.receiver.class.name === Object.name
        # If the receiver is an Object, it's probably #main, in which case we can just print it directly
        "#{method.receiver}::#{method.name}"

      elsif method.receiver.class.name == Class.name
        # If the receiver is the base Class, then we're dealing with a class method so we have a class ref already
        "#{method.receiver.name}::self.#{method.name}"

      else
        # If the receiver is some child class class, we want to use the class name in printable output
        "#{method.receiver.class.name}::#{method.name}"
      end

      start_time  = Time.now
      begin
        method.run_inline_tests # Throws an exception on fail
        test_time    = Time.now - start_time
        test_passes += 1

        puts "  #{method_signature} - PASSED (#{format_tiny_time test_time} seconds)"

      rescue InlineTestFailure => failure_information
        test_time   = Time.now - start_time
        errors      = failure_information
        test_fails += 1

        puts "  #{method_signature} - FAILED (#{format_tiny_time test_time} seconds)"
        puts errors
      end
    end
    all_tests_end_time = Time.now

    # Print overall test results & stats
    # print_results(method_passing, method_errors)
    puts "#{METHODS_WITH_INLINE_TESTS.count} inline tests ran in #{format_tiny_time all_tests_end_time - all_tests_start_time} seconds."
    puts "  #{test_passes} PASSED"
    puts "  #{test_fails} FAILS"
    puts
    puts "#{METHODS_THAT_NEED_TESTS.count} methods still need tests:"
    METHODS_THAT_NEED_TESTS.each do |method|
      puts "  #{method.receiver.name}##{method.original_name}"
      puts "    #{method.source_location.join(':')}"
    end

    # Intentionally return nil so we don't re-output what we just printed as a return value
    nil
  end

  private

  def self.format_tiny_time(time)
    sprintf('%.15f', time).sub(/0+$/, '').sub(/\.$/, '.0')
  end
end