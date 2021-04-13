class InlineTestFailure < StandardError
  attr_accessor :test_type, :lhs, :rhs, :description

  def initialize(test_type=nil, lhs=nil, rhs=nil, description=nil)
    super [
      "#{description} FAILED:",
      "      test_type: #{test_type}",
      "      lhs: #{lhs}",
      "      rhs: #{rhs}"
    ].join "\n"
    self.test_type = test_type
    self.lhs = lhs
    self.rhs = rhs
    self.description = description
  end
end