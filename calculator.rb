class Calculator
  OPERATORS = ["+", "-", "*", "/"]
  PRIORITY_OPERATORS = ["*", "/"]
  NONPRIORITY_OPERATORS = ["+", "-"]
  
  attr_accessor :str_input
  attr_accessor :input_as_array
  
  def initialize(str)
    @str_input = str
  end
  
  def calculate(str = nil)
    @str_input = str if str
    @input_as_array = @str_input.split
    raise "Input is invalid" unless input_valid?
    
    make_calculation
  end
  
  def make_calculation
    return input_as_array.first.to_f if input_as_array.length == 1
    operator_index = find_operator_index(PRIORITY_OPERATORS)
    operator_index = find_operator_index(NONPRIORITY_OPERATORS) unless operator_index
    make_one_calculation(operator_index)
    return make_calculation
  end
  
  def find_operator_index(list_of_operators)
    operator_index = nil
    
    input_as_array.each_with_index do |operator, index|
      if list_of_operators.include?(operator)
        operator_index = index
        break
      end
    end
    
    operator_index
  end
  
  def make_one_calculation(operator_index)
    result = input_as_array[operator_index - 1].to_f.send(input_as_array[operator_index], input_as_array[operator_index + 1].to_f)
    input_as_array.slice!((operator_index - 1)..(operator_index + 1))
    input_as_array.insert(operator_index - 1, result)
  end
  
  def input_valid?
    return false if input_as_array.length % 2 == 0
    val_should_be_int = true
    
    input_as_array.each do |value|
      is_valid = val_should_be_int ? Calculator.value_is_num?(value) : Calculator.value_is_operator?(value)
      return false unless is_valid
      val_should_be_int = !val_should_be_int
    end
    
    return true
  end
  
  def self.value_is_num?(val)
    val && (val == val.to_f.to_s || val == val.to_i.to_s)
  end
  
  def self.value_is_operator?(val)
    val && OPERATORS.include?(val)
  end
end

describe Calculator do
  before(:each) do
    @calculator = Calculator.new("5 + 4")
  end
  
  describe "#calculate" do
    it "sets the attribute str_input if an argument is passed in" do
      input_str = "1555 + 1555"
      expect(@calculator.str_input).not_to eq(input_str)
      @calculator.calculate(input_str)
      expect(@calculator.str_input).to eq(input_str)
    end
    
    it "does not change the value of str_input if an argument is not passed in" do
      input_str = @calculator.str_input
      @calculator.calculate
      expect(@calculator.str_input).to eq(input_str)
    end
    
    it "raises an error if the input is invalid" do
      @calculator.should_receive(:input_valid?).and_return(false)
      @calculator.should_not_receive(:make_calculation)
      expect{@calculator.calculate}.to raise_error("Input is invalid")
    end
    
    it "calls make_calculation if the input is valid" do
      @calculator.should_receive(:input_valid?).and_return(true)
      @calculator.should_receive(:make_calculation)
      @calculator.calculate
    end
  end
  
  describe "#make_calculation" do
    it "does the correct order of operation" do
      @calculator.input_as_array = ["5", "+", "5", "*", "5", "/", "5", "-", "20"]
      value = @calculator.make_calculation
      expect(value).to eq(-10)
    end
    
    context "there is only 1 input value in the array" do
      it "returns the only value in the array" do
        @calculator.input_as_array = ["500"]
        expect(@calculator.make_calculation).to eq(500)
      end
    end
  end
  
  describe "#find_operator_index" do
    it "returns the index of the first matching operator" do
      @calculator.input_as_array = ["5", "+", "5", "*", "5", "/", "5", "-", "20"]
      expect(@calculator.find_operator_index(["*", "/"])).to eq(3)
    end
    
    it "returns nil if the a matching operator is not found" do
      @calculator.input_as_array = ["10", "+", "-", "*"]
      expect(@calculator.find_operator_index(["/"])).to be nil
    end
  end
  
  describe "#make_one_calculation" do
    it "makes the calculation and condenses the array of values" do
      @calculator.input_as_array = ["5", "+", "5", "/", "5", "-", "20"]
      @calculator.make_one_calculation(5)
      expect(@calculator.input_as_array).to eq(["5", "+", "5", "/", -15])
    end
  end
  
  describe "#input_valid?" do
    it "returns true if the the first and last values are numbers, and the numbers and operators alternate" do
      @calculator.input_as_array = ["5", "+", "5", "/", "5", "-", "20"]
      expect(@calculator.input_valid?).to be true
    end
    
    it "returns false if there are consecutive numbers" do
      @calculator.input_as_array = ["5", "5", "+", "2", "5"]
      expect(@calculator.input_valid?).to be false
    end
    
    it "returns false if there are consecutive operators" do
      @calculator.input_as_array = ["5", "+", "+"]
      expect(@calculator.input_valid?).to be false
    end
    
    it "returns false if there are an even number of inputs" do
      @calculator.input_as_array = ["5", "+", "5", "/"]
      expect(@calculator.input_valid?).to be false
    end
  end
  
  describe "::value_is_num?" do
    it "returns true if the string is an integer value" do
      expect(Calculator.value_is_num?("123")).to be true
    end
    
    it "returns true if the string is a decimal" do
      expect(Calculator.value_is_num?("0.123")).to be true
    end
    
    it "returns false if the value is not a numerical value" do
      expect(Calculator.value_is_num?("123a")).to be false
    end
  end
  
  describe "::value_is_operator?" do
    it "returns true if the string exists in the array of OPERATORS" do
      expect(Calculator.value_is_operator?("+")).to be true
      expect(Calculator.value_is_operator?("-")).to be true
      expect(Calculator.value_is_operator?("*")).to be true
      expect(Calculator.value_is_operator?("/")).to be true
    end
    
    it "returns false if the string does not exist in the array of OPERATORS" do
      expect(Calculator.value_is_operator?("&")).to be false
    end
  end
end