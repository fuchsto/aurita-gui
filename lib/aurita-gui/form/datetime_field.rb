
require('aurita-gui/form/date_field')
require('aurita-gui/form/select_field')

module Aurita
module GUI

  class Datetime_Field < Date_Field
    attr_accessor :hour, :minute, :second, :hour_element, :minute_element, :second_element, :time_format

    def initialize(params, &block)
      @time_format   = params[:time_format]
      @time_format ||= 'hms'

      params.delete(:time_format)
      params.delete(:hour)
      params.delete(:minute)
      params.delete(:second)
      super(params, &block)
    end

    def hour_element
      if !@hour_element then
        @hour_element = Select_Field.new(:name  => @attrib[:name].to_s + '_hour', 
                                         :class => :hour_select, 
                                         :value => @hour, :options => (0..23))
      end
      @hour_element
    end
    def minute_element
      if !@minute_element then
        @minute_element = Select_Field.new(:name  => @attrib[:name].to_s + '_minute', 
                                          :class => :minute_select, 
                                          :value => @minute, :options => (0..59))
      end
      @minute_element
    end
    def second_element
      if !@second_element then
        @second_element = Select_Field.new(:name  => @attrib[:name].to_s + '_second', 
                                           :class => :second_select, 
                                           :value => @second, :options => (0..59))
      end
      @second_element
    end

    def element
      select_fields = []
      @date_format.scan(/./).each { |c|
        case c
        when 'y' then
          select_fields << year_element() 
        when 'm' then
          select_fields << month_element() 
        when 'd' then
          select_fields << day_element() 
        end
      }
      @time_format.scan(/./).each { |c|
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

    def value=(date)
      case date 
      when Hash then
        @value = date
      when Datetime then
        @value = { :hour   => date.hour, 
                   :minute => date.month, 
                   :second => date.second }
      when Date then
        @value = { :hour   => date.hour, 
                   :minute => date.minute, 
                   :second => date.second }
      when String then
#       date = Datetime.strptime(date)
#       @value = { :hour   => date.hour, 
#                  :minute => date.minute, 
#                  :second => date.second }
      else
      end
    end

    def value
      super().update(:second => @second, :minute => @minute, :hour => @hour)
    end
  end
  
end
end
