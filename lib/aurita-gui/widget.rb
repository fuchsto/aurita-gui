
require('delegate')
require('aurita-gui/element')

module Aurita
module GUI

  class Widget < DelegateClass(Element)
  include Aurita::GUI

    def initialize()
      super(element())
    end

    def element
      raise ::Exception.new('Missing method #element for ' << self.class.to_s)
    end

    def js_initialize
      ''
    end

  end

end
end

