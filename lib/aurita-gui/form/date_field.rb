
require('aurita-gui/form/form_field')
require('aurita-gui/form/select_field')

module Aurita
module GUI

  class Date_Field < Form_Field
    attr_accessor :day, :month, :year, :years, :day_element, :month_element, :year_element, :date_format

    def initialize(params, &block)
      @date_format   = params[:date_format]
      @date_format ||= 'mdy'
      @year_range    = params[:year_range]
      @year_range  ||= (2009..2020)

      set_value(params[:value]) 

      params.delete(:value)
      params.delete(:date_format)
      params.delete(:date)
      params.delete(:day)
      params.delete(:month)
      params.delete(:year)
      params.delete(:year_range)
      super(params, &block)
    end

    # Set years that are available for selection. 
    # Example: 
    #
    #   my_date_field.year_range = (2010..2020)
    #
    def year_range=(range)
      @year_range = range
      touch
    end

    def year_element
      if !@year_element then
        @year_element = Select_Field.new(:name  => @attrib[:name].to_s + '_year', 
                                         :class => :year_select, 
                                         :value => @year, :options => @year_range)
      end
      @year_element
    end
    def month_element
      if !@month_element then
        @month_element = Select_Field.new(:name  => @attrib[:name].to_s + '_month', 
                                          :class => :month_select, 
                                          :value => @month, :options => (1..12))
      end
      @month_element
    end
    def day_element
      if !@day_element then
        @day_element = Select_Field.new(:name  => @attrib[:name].to_s + '_day', 
                                        :class => :day_select, 
                                        :value => @day, :options => (1..31))
      end
      @day_element
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
      HTML.div(@attrib) { 
        select_fields
      }
    end

    def value=(date)
      return unless date

      case date 
      when Hash then
        @value = date
      when ::DateTime then
        @value = { :year  => date.year, 
                   :month => date.month, 
                   :day   => date.day }
      when Date then
        @value = { :year  => date.year, 
                   :month => date.month, 
                   :day   => date.day }
      when String then
        date = (::DateTime).strptime(date, "%Y-%m-%d")
        @value = { :year  => date.year, 
                   :month => date.month, 
                   :day   => date.day }
      else
        return
      end
      @year, @month, @day = @value[:year], @value[:month], @value[:day]
    end
    alias set_date value=
    alias set_value value=

    def value
      { :day => @day, :month => @month, :year => @year }
    end
  end
  
end
end
