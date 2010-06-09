
class String

  # Sets sanitized flag, indicating that 
  # this string does not have to be escaped 
  # before rendering. 
  # This does not affect the string, it just 
  # prevents it from being HTML-encoded when 
  # being rendered. 
  # To also escape a string, use #sanitize!, 
  # which uses HTMLEntities to encode it. 
  #
  def sanitized
    @sanitized = true
    return self
  end

  # Whether this string has to be escaped 
  # before rendering. 
  #
  # When rendering an Element instance, the #sanitize! 
  # method is called automatically on child elements 
  # if their #sanitized? method returns false. 
  #
  def sanitized?
    @sanitized || false
  end

  # Sanitize this string by HTML-encoding it 
  # using HTMLEntities. 
  #
  # Note that this method is called automatically 
  # on every content of Aurita::GUI::Element 
  # instances that is not flagged as sanitized, 
  # so you don't have to do it yourself. 
  #
  # When in doubt, use this method instead of 
  # #sanitized, as it just returns self if 
  # it has been sanitized already. 
  #
  def sanitize!
    return self if @sanitized
    replace(HTMLEntities.new.encode(self))
    @sanitized = true
    return self
  end

end

class Array

  # Sets sanitized flag, indicating that 
  # elements in this array does not have to be 
  # escaped before rendering. 
  # This does not affect the elements, it just 
  # prevents them from being HTML-encoded when 
  # being rendered. 
  # To also escape array elements, use #sanitize!, 
  # which uses HTMLEntities to encode them. 
  #
  # Note that #sanitize! is called automatically 
  # on every content of Aurita::GUI::Element 
  # instances that is not flagged as sanitized, 
  # so you don't have to do it yourself. 
  #
  def sanitized
    @sanitized = true
    return self
  end

  # Whether all elements in this array are sane. 
  #
  # When rendering an Element instance, the #sanitize! 
  # method is called automatically on child elements 
  # if their #sanitized? method returns false. 
  #
  def sanitized?
    return true if @sanitized
    each { |e| 
      if !e.respond_to?(:sanitized?) || !e.sanitized? then
        return false 
      end
    }
    @sanitized = true
    return true
  end

  # HTML-encodes every element that is not 
  # flagged as sanitized by calling their 
  # #sanitize! method. 
  #
  # Note that this method is called automatically 
  # on every content of Aurita::GUI::Element 
  # instances that is not flagged as sanitized, 
  # so you don't have to do it yourself. 
  #
  # When in doubt, use this method instead of 
  # #sanitized, as it just returns self if 
  # it has been sanitized already. 
  #
  def sanitize!
    return self if @sanitized
    each { |e|
      e.sanitized? || e.sanitize!
    }
    @sanitized = true
    return self
  end

end

