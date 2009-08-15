
module Aurita
module GUI

  module Marshal_Helper
    def marshal_dump
      c = { :tag => @tag, :content => @content }
      @attrib.update(c)
    end
  end

  module Marshal_Helper_Class_Methods
    def marshal_load(dump)
      self.new(dump)
    end
  end

  class Element
    include Marshal_Helper
    extend Marshal_Helper_Class_Methods
  end

end
end

