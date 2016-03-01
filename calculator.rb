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
