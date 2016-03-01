require_relative "calculator"

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