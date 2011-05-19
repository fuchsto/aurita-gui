
require('aurita-gui/form/date_field')
require('aurita-gui/form/select_field')

module Aurita
module GUI

  class Time_Field < Form_Field
    attr_accessor :hour, :minute, :second, :hour_element, :minute_element, :second_element, :time_format, :minute_range

    def initialize(params, &block)
      @time_format   = params[:time_format]
      @time_format ||= 'hms'

      @value = {}
      @minute_range = params[:minute_range]
      set_value(params[:value])

      params.delete(:minute_range)
      params.delete(:time_format)
      params.delete(:hour)
      params.delete(:minute)
      params.delete(:second)
      params.delete(:value)
      super(params, &block)
    end

    def hour_element
      if !@hour_element then
        options = (0..23)
        options = options.to_a.map { |e| (e < 10)? ('0' << e.to_s) : e.to_s }
        @hour_element = Select_Field.new(:name  => @attrib[:name].to_s + '_hour', 
                                         :id    => @attrib[:name].to_s + '_hour', 
                                         :class => :hour_select, 
                                         :value => @hour, :options => options)
      end
      @hour_element
    end
    def minute_element
      if !@minute_element then
        options   = @minute_range
        options ||= (0..59)
        options = options.to_a.map { |e| (e < 10)? ('0' << e.to_s) : e.to_s }
        @minute_element = Select_Field.new(:name  => @attrib[:name].to_s + '_minute', 
                                           :id    => @attrib[:name].to_s + '_minute', 
                                           :class => :minute_select, 
                                           :value => @minute, :options => options)
      end
      @minute_element
    end
    def second_element
      if !@second_element then
        options = (0..59)
        options = options.to_a.map { |e| (e < 10)? ('0' << e.to_s) : e.to_s }
        @second_element = Select_Field.new(:name  => @attrib[:name].to_s + '_second', 
                                           :id    => @attrib[:name].to_s + '_second', 
                                           :class => :second_select, 
                                           :value => @second, :options => options)
      end
      @second_element
    end

    def element
      select_fields = []
      @time_format.to_s.split('').each { |c|
        case c
        when 'h' then
          select_fields << hour_element() 
        when 'm' then
          select_fields << minute_element() 
        when 's' then
          select_fields << second_element() 
        end
      }
      HTML.div(@attrib) { 
        select_fields
      }
    end

    def value=(time)

      case time 
      when Hash then
        @value = time
      when Datetime then
        @value = { :hour   => time.hour, 
                   :minute => time.month, 
                   :second => time.second }
      when Date then
        @value = { :hour   => time.hour, 
                   :minute => time.minute, 
                   :second => time.second }
      when String then
        value_parts = time.split(':')
        count       = 0
        @time_format.scan(/./).each { |c|
          case c
          when 'h' then
            @hour = value_parts[count]
            @value[:hour]   = @hour
            count += 1
          when 'm' then
            @minute = value_parts[count]
            @value[:minute] = @minute
            count += 1
          when 's' then
            @second = value_parts[count]
            @value[:second] = @second
            count += 1
          end
        }
      else
      end
      @hour   ||= "00"
      @minute ||= "00"
      @second ||= "00"
    end
    alias set_value value=

    def value
      { :second => @second, :minute => @minute, :hour => @hour }
    end
  end
  
end
end
