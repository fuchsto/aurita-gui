
require('aurita-gui/form/form_field')
require('aurita-gui/form/select_field')
require('aurita-gui/form/options_field')

module Aurita
module GUI

  class Selection_List_Option_Field < Form_Field
    def initialize(params={})
      params.delete(:selection_list_params)
      super(params)
    end
    def element
      HTML.div(:id => "selection_option_#{@attrib[:name]}_#{@value}", :class => :selection_list_option) { 
        HTML.label { @label.to_s } +
        Hidden_Field.new(:value => @value, :name => @attrib[:name].to_s + '_selected[]')
      }
    end
  end

  # A selection list maintains a list of 
  # available options and a select field of
  # further available options. 
  #
  # == Example: 
  #
  #   Selection_List_Field.new(:name => :the_list, 
  #                            :value => ['10','30' ]          # Active selection from options
  #                            :options => { '10' => :blue,    # List of all options
  #                                          '20' => :red, 
  #                                          '30' => :green }
  # 
  # In the example, any combination of 'blue', 
  # 'red' and 'green' could be selected, 
  # here it is 'blue' and 'green'. 
  # The select field contains 20 => 'red', 
  # the only additionally available option 
  # (as it is not already set in value). 
  #
  # Use case: Assign user to categories. 
  # Options is all available categories, 
  # value is an array of category ids 
  # already assigned to this user. 
  #
  # == Customization 
  #
  # You can override the Form_Field class 
  # rendering the option list elements, as 
  # well as the Form_Field class rendering 
  # the select field. 
  #
  # Use #option_field_decorator to override 
  # rendering of option fields. 
  # Default is Selection_List_Option_Field. 
  #
  # Example for custom option field decorator: 
  #
  #   class Delete_Option_Decorator < Form_Field
  #     def element
  #       HTML.div { 
  #         HTML.img(:src => '/images/delete.png') + @label
  #       }
  #     end
  #   end
  #
  #   selection_list.option_field_decorator = Delete_Option_Decorator
  #
  # Example for custom select field class: 
  #
  # Note that Selection_List_Field will initialize 
  # @select_field_class with parameter :options, a 
  # key / label map of available options. 
  #   
  #   class Ajax_Selection_Field < Form_Field
  #     def initialize(params={})
  #       super(params)
  #       params[:onchange] = js.do_something.ajaxian.with(:this, @options)
  #     end
  #     def element
  #       HTML.div { 
  #         Input_Field.new(@attrib) 
  #       }
  #     end
  #   end
  #
  #   selection_list.select_field_class = Ajax_Selection_Field
  # 
  class Selection_List_Field < Options_Field

    attr_accessor :option_field_decorator, :select_field_class, :selectable_options

    def initialize(params={})
      @option_field_decorator ||= params[:option_field]
      @select_field_class     ||= params[:select_field]
      @option_field_decorator ||= Selection_List_Option_Field
      @select_field_class     ||= Select_Field
      @selectable_options     ||= params[:selectable_options]
      @selectable_options     ||= []

      params.delete(:option_field)
      params.delete(:select_field)
      params.delete(:selectable_options)
      super(params)
      set_value(@value) 
      add_css_class(:selection_list_field)
    end

    # Set list of all options as value / label hash. 
    def options=(options)
      super(options)
      if !@selectable_options || @selectable_options.length == 0 then
        options().each_pair { |value, name|
          @selectable_options << value unless (@value.is_a?(Array) && @value.map { |v| v.to_s }.include?(value.to_s))
        }
      end
    end

    # Set list of active selection options as array. 
    def value=(value)
      return unless value
      super(value)
      @selectable_options = []
      options().each_pair { |value, name|
        @selectable_options << value unless @value.map { |v| v.to_s }.include? value.to_s
      }
    end
    alias set_value value=

    # Returns array of available options, 
    # decorated by @option_field_decorator 
    # (see comments on Selection_List_Field). 
    def option_elements
      base_id   = @attrib[:id]
      base_id ||= @attrib[:name]
      elements = []
      options().each_pair { |opt_value, opt_label|
        selected = @value.map { |v| v.to_s }.include?(opt_value.to_s)
        if selected then
          elements << HTML.li(:id => "#{base_id}_#{opt_value}") { 
            @option_field_decorator.new(:name   => @attrib[:name], 
                                        :value  => opt_value, 
                                        :label  => opt_label, 
                                        :parent => self)
          }
        end
      }
      elements
    end

    # Renders list of active options, as well 
    # as select field element containing additionally 
    # available options. 
    def element
      select_options = []
      select_option_ids = []
      @selectable_options.each { |v|
        select_option_ids << v 
        select_options << @option_labels[v]
      }
      select_options.fields = select_option_ids 

      base_id   = @attrib[:id]
      base_id ||= @attrib[:name]
      
      if @value && @value.length > 0 then
        HTML.div(@attrib) { 
          HTML.ul(:id => "#{base_id}_selected_options") { 
            option_elements()
          } + 
          @select_field_class.new(:id      => "#{base_id}_select", 
                                  :options => select_options, 
                                  :parent  => self, 
                                  :name    => "#{@attrib[:name]}" ) 
        }
      else
        HTML.div(@attrib) { 
          HTML.ul(:id => "#{base_id}_selected_options", :force_closing_tag => true)  + 
          @select_field_class.new(:id      => "#{base_id}_select", 
                                  :options => select_options, 
                                  :parent  => self, 
                                  :name    => "#{@attrib[:name]}" ) 
        }
      end
    end

    def readonly_element
      base_id   = @attrib[:id]
      base_id ||= @attrib[:name]
      elements = HTML.ul.readonly_selection_list { } 
      options().each_pair { |opt_value, opt_label|
        selected = @value.map { |v| v.to_s }.include?(opt_value.to_s)
        if selected then
          elements << HTML.li(:id => "#{base_id}_#{opt_value}") { opt_label }
        end
      }
      elements
    end

  end

end
end

