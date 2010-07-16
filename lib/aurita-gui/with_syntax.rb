

class With_Builder 

  def initialize(obj, &block)
    @obj = obj
    instance_eval(&block)
  end

  def method_missing(meth, *args)
    @obj.__send__(meth, *args)
  end

end

module Kernel

  # Implementation of a generic with(obj) Syntax. 
  # Usage: 
  #
  #   a = [ 1,2,3,4 ]
  #
  #   with(a) { 
  #     push 'b'
  #     push 'c'
  #   }
  #
  #   p a 
  #   --> [ 1,2,3,4,'b','c']
  #
  def with(obj, &block)
    With_Builder.new(obj, &block)
  end

end



