
require('aurita-gui/form/form_field')
require('arrayfields')

module Aurita
module GUI
  # TODO: Use ArrayFields for option field/value storage

  # Abstract base class for all form elements containing
  # options, like Select_Field, Radio_Field, Checkbox_Field
  # or any custom implementation. 
  #
  # Usage: 
  #
  #   r = Radio_Field.new(:options => { 1 => 'first', 
  #                                     2 => 'second', 
  #                                     3 => 'third' },
  #                       :label => 'Which one?', 
  #                       :value => 1)
  # Same as
  #
  #   r = Radio_Field(:option_range  => (1..3)
  #                   :option_labels => ['First', 'Second', 'Third']
  #                   :value => 1,
  #                   :label => 'Which one?')
  #
  # Set a selected value using parameter :value
  #
  #   r = Radio_Field.new(:value => 42, :name => :amount, 
  #                       :label => 'Select amount')
  #   r.value = 23
  #
  # If there may be more than one selected field, e.g. for Checkbox_Field, 
  # @value is an Array instance: 
  #
  #   c = Checkbox_Field.new(:value => [ 1, 3 ], 
  #                          :options => { 1 => 'first', 2 => 'second', 3 => 'third' }, 
  #                          :label => 'Choose')
  #   c.value = [ 2, 3 ]
  #
  #
  # There are many ways to define options: 
  #
  #   select = Select_Field.new(:name => :category, :label => 'Category') 
  #   select.options = { 1 => 'first', 2 => 'second' } 
  #   select.add_option(3 => 'third')
  #   select[3] = HTML.option(:value => 4) { 'fourth' }
  #   select[4] = { 5 => 'fifth' }
  #
  # 
  # == Setting option values and labels
  #
  # There are a zillion ways to set option values and labels. 
  # The following examples all use Select_Field, but this
  # behaviour applies to all derivates of Options_Field. 
  # 
  # If there are no option labels set, 
  # option values will be displayed directly: 
  #
  #   s1 = Select_Field.new(:name => :test, 
  #                         :label => 'Priority', 
  #                         :options => (1..10)) # Option labels are 0..10
  # 
  # Set option values and labels at once using a hash: 
  #
  #   s1 = Select_Field.new(:name => :test, 
  #                         :label => 'Pick one', 
  #                         :options => { 1 => 'eins', 2 => 'zwei', 3 => 'drei' })
  # 
  # Set option values as array, labels as hash: 
  #
  #   s1 = Select_Field.new(:name => :test, 
  #                         :label => 'Pick one', 
  #                         :option_labels => [ 'foo', 'bar', 'wombat' ] }, 
  #                         :option_values => [ 1,2,3 ])
  # Ranges are ok, too: 
  #
  #   s1 = Select_Field.new(:name => :test, 
  #                         :label => 'Pick one', 
  #                         :option_labels => [ 'foo', 'bar', 'wombat' ], 
  #                         :options => (1..3))
  # 
  # Change option labels using an array. 
  # Option labels will be assigned in order, 
  # so options[0] has label[0] etc.
  #
  #   s1.option_labels = [ 'first', 'second', 'third' ]
  # 
  # Change option labels using a hash. 
  # Compared to using an array, this is useful 
  # in case you don't know the order of option 
  # values. You can also rename some or all option 
  # labels this way. 
  #
  #   s1.option_labels = { 1 => 'ras', 2 => 'dwa', 3 => 'tri' }
  # 
  # Of yourse you can replace all option values 
  # and their labels at once by overwriting 
  # the options field: 
  #
  #   s1.label = 'Choose'
  #   s1.options = { 1 => :foo, 2 => :bar, 3 => :wombat }
  #
  class Options_Field < Form_Field

    attr_accessor :option_values, :option_labels
    attr_reader :value

    def initialize(params, &block)
      @option_labels     = params[:option_labels]
      @option_labels   ||= []
      @option_values     = params[:option_values]
      @option_values   ||= []
      @value             = params[:value]

      set_options(params[:options]) if params[:options]

      if block_given? then
        yield.each { |option|
          add_option(option)
        }
      elsif params[:options] and !params[:option_labels] then
        add_option(params[:options])
      end
      params.delete(:options)
      # Option fields don't have a value attribute themselves
      params.delete(:value) 
      params.delete(:option_values)
      params.delete(:option_labels)
      super(params)
    end

    def options
      @option_labels = @option_values.dup unless @option_labels.length > 0
      @option_labels.fields = @option_values.map { |v| v.to_s } 
      @option_labels
    end

    def option_hash
      options().to_hash
    end

    def option_labels=(labels)
      # [ :red, :blue, :green, :yellow ]
      if labels.kind_of? Array then
        @option_labels = labels
      # { 0 => :red, 1 => :blue }
      elsif labels.kind_of? Hash then
        @option_labels ||= []
        @option_values ||= []
        # Ensure keys and values are strings: 
        labels.each_pair { |k,v|
          labels.delete(k)
          labels[k.to_s] = v
        }
        opt_field = options()
        labels.sort.each { |pair|
          opt_field[pair[0].to_s] = pair[1]
        }
      end
    end
    alias set_option_labels option_labels=

    def add_option(option={})
      if option.kind_of? Array then
        @option_values += option
      elsif option.kind_of? Range then
        @option_values += option.to_a
      elsif option.kind_of? Hash then
      #  @option_elements << options
      end
    end

    def options=(options)
      if options.kind_of? ArrayFields then
        @option_values = options.fields
        @option_labels = options.values
      elsif options.kind_of? Array then
        @option_values = options
        @option_labels = options
      elsif options.kind_of? Range then
        @option_values = options.to_a
        @option_labels = options.to_a
      elsif options.kind_of? Hash then
        @option_values = []
        @option_labels = []
        options.sort.each { |pair|
          @option_values << pair[0]
          @option_labels << pair[1]
        }
      end
    end
    alias set_options options=

    def value=(value)
      @value = value
    end
    alias set_value value=

    def [](index)
      @option_elements[index]
    end
    def []=(index, option_element)
      @option_elements[index] = option_element
    end

    def element
      raise Form_Error.new('Method #element from Abstract class Options_Field has not been overloaded in ' << self.class.to_s)
    end

    def readonly_element
      opt = options()
      return HTML.div(@attrib) { opt[@value] } if (opt && @value.to_s != '' && opt[@value])
      return HTML.div(@attrib) { @value } 
    end

    def content
      option_elements()
    end
  end
  
end
end
