
require 'rubygems'
require 'aurita-gui'

include Aurita::GUI


class Renderfoo

  def outerfun(i)
    i * i
  end

  def render
    puts HTML.build { 
      outerfun(23) 
    }.to_s
  end

end

Renderfoo.new.render
