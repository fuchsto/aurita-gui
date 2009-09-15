
require('aurita-gui/element')
require('aurita-gui/html')
require('aurita-gui/form/form_field')
require('aurita-gui/form/form_error')
require('aurita-gui/form/input_field')
require('aurita-gui/form/hidden_field')
require('aurita-gui/form/options_field')
require('aurita-gui/form/select_field')
require('aurita-gui/form/radio_field')
require('aurita-gui/form/checkbox_field')
require('aurita-gui/form/fieldset')
require('aurita-gui/form/textarea_field')
require('aurita-gui/form/date_field')
require('aurita-gui/form/time_field')
require('aurita-gui/form/datetime_field')
require('aurita-gui/form/file_field')
require('aurita-gui/form/boolean_field')
require('aurita-gui/form/text_field')
require('aurita-gui/form/password_field')
require('aurita-gui/form/selection_list')

module Aurita
module GUI


  # Default decorator for form fields. 
  # Decorates single entry of form to <li> element, setting CSS 
  # classes and DOM ids. 
  # To use your own field decorator, derive it from Aurita::GUI::Element
  # (maybe indirectly via one of its derivates) and define its 
  # constructor to expect a single Form_Field instance. 
  # The field decorator has to wrap the actual form field. 
  #
  # See the source code of Aurita::GUI::Form_Field_Wrapper for a
  # simple implementation. 
  #
  # Tell a form to use a specific field decorator by 
  #
  #   the_form.field_decorator = My_Field_Decorator
  #
  # To use your own implementation as defaut, overload Form.initialize 
  # like
  #
  #   class My_Form < Aurita::GUI::For
  #     def initialize(params={}, &block)
  #       super(params, &block)
  #       @field_decorator = My_Field_Decorator
  #     emd
  #   end
  #
  # Or write a factory (*hint hint*) like: 
  #
  #   class Form_Factory
  #     def self.form(params={}, &block)
  #       form = Aurita::GUI::Form.new(params, &block)
  #       form.field_decorator = My_Field_Decorator
  #       return form
  #     end
  #   end
  #
  # See also: Form_Content_Wrapper (pretty much the same). 
  #
  class Form_Field_Wrapper < Aurita::GUI::Element
    attr_accessor :field

    def initialize(field)
      label_params = false
      if field.label then
        label_params = { :for => field.dom_id, :force_closing_tag => true }
        label_params[:id] = field.dom_id.to_s + '_label' if field.dom_id
        label = field.label
        @content = [ HTML.label(label_params) { label }, field ]
      else 
        @content = field
      end
      field.dom_id = field.name.to_s.gsub('.','_') unless field.dom_id

      # Inherit css classes from decorated field, if any: 
      css_classes   = field.css_class.map { |c| c.to_s + '_wrap' if c }
      css_classes ||= []

      css_classes << field.class.to_s.split('::')[-1].downcase + '_wrap form_field' 
      css_classes << ' required' if field.required?
      css_classes << ' invalid' if field.invalid?
      params = { :tag => :li, 
                 :content => @content, 
                 :id => field.dom_id.to_s + '_wrap', 
                 :class => css_classes }
      super(params)
    end

  end

  # Default decorator for form contents (list of form fields). 
  # Decorates all entries of form to <ul> element, setting CSS 
  # class 'form_field'.
  # To use your own field decorator, derive it from Aurita::GUI::Element
  # (maybe indirectly via one of its derivates) and define its 
  # constructor to expect a list of Form_Field instances as 
  # content attribute (either in params or as block). 
  # The content decorator has to wrap the actual array of form fields. 
  #
  # See the source code of Aurita::GUI::Form_Content_Wrapper for a
  # simple implementation. 
  #
  # Tell a form to use a specific content decorator by 
  #
  #   the_form.content_decorator = My_Content_Decorator
  #
  # To use your own implementation as defaut, overload Form.initialize 
  # like
  #
  #   class My_Form < Aurita::GUI::Form
  #     def initialize(params={}, &block)
  #       super(params, &block)
  #       @content_decorator = My_Content_Decorator
  #     emd
  #   end
  #
  # Or write a factory (*hint hint*) like: 
  #
  #   class Form_Factory
  #     def self.form(params={}, &block)
  #       form = Aurita::GUI::Form.new(params, &block)
  #       form.content_decorator = My_Content_Decorator
  #       return form
  #     end
  #   end
  #
  # See also: Form_Field_Wrapper (pretty much the same). 
  # 
  class Form_Content_Wrapper < Aurita::GUI::Element
    def initialize(params={}, &block)
      params[:tag]     = :ul
      params[:class]   = :form_fields
      super(params, &block)
    end
  end

  # Usage examples: 
  #
  #   form = Form.new(:method   => :put  # default: :post
  #                   :action   => '/where/to/send/form/'
  #                   :onsubmit => "alert('submitting');") { 
  #     [ 
  #       Input_Field.new(:name => :description, :label => 'Description'), 
  #       Select_Field.new(:name => :category, :label => 'Select category')
  #     ]
  #   }
  #   textarea = GUI::Textarea.new(:name => :comment, :label => 'Comment')
  #   form.add(textarea)
  #
  # === Rails
  #
  # In Rails, you could use form instances like: 
  #
  #    class ItemController < ActionController::Base
  #      def add
  #        @form = Form.new(:action => 'where/to/send')
  #        @form[:title].required! 
  #      end
  #    end
  #
  # And in view 'item/add': 
  #
  #   <% 
  #     @form[:title].value = 'Enter a title here' 
  #     @form[:description].disabled! unless @may_edit_description
  #   %>
  #
  #   <%= @form.string %>
  #
  # You can also use form template helpers from 
  # Aurita::GUI::Form_Field_Helpers. 
  # You'd have to define you own form builder class, but that's 
  # quite simple (see comments on module Form_Field_Helpers). 
  # I'll soon provide a Rails-specific form builder, though. 
  #
  # == Render modes
  #
  # There are several ways to influence the rendering of a 
  # field. 
  # Available modes are: 
  #
  #   * editable: Default mode, opposite of readonly mode. 
  #   * disabled: Set the disabled="disabled" attribute. Element will 
  #               be rendered as input field, but can't be modified 
  #               by the user. 
  #   * readonly: Unlike in disabled mode, element will not be rendered 
  #               as input field, but as a <div> containing the field's value. 
  #   * required: Always render this field. If it is not included in the 
  #               form's field configuration, render it as hidden field. 
  #   * hidden:   Render as hidden field. 
  #
  # === Examples
  #
  #   form = Form.new(:name   => :the_form, 
  #                   :id     => :the_form_id, 
  #                   :action => :where_to_send)
  #
  #
  # You can either set all attributes in the 
  # constructor call ...
  #
  #   text = Input_Field.new(:name => :description, 
  #                          :class => :the_css_class, 
  #                          :label => 'Enter description', 
  #                          :onfocus => "alert('input focussed');", 
  #                          :value => 'some text')
  #
  # Or set them afterwards: 
  #
  #   text.onblur = "alert('i lost focus :(');"
  # 
  # Default mode: 
  #
  #   puts text.to_s
  #
  # Disabled mode: 
  #
  #   text.disable! 
  #   puts text.to_s
  # 
  # Re-enable: 
  #
  #   text.enable! 
  #   puts text.to_s
  #
  # Readonly: 
  #
  #   text.readonly! 
  #   puts text.to_s
  #
  # Back to editable: 
  #
  #   text.editable! 
  #   puts text.to_s
  # 
  # Render to hidden field: 
  #
  #   puts text.to_hidden_field.to_s
  #
  # Set to hidden (will only influence handling when 
  # rendered by a form): 
  #
  #   text.hidden = true
  # 
  # Add it to the form: 
  #
  #   form.add(text)
  #
  # === Modifying form elements  
  #
  # Access it again, by name: 
  # 
  #   assert_equal(form[:description], text)
  #
  # Or by using its index: 
  #
  #   assert_equal(form[0], text)
  # 
  # This is useful! 
  #
  #   form[:description].value = 'change value'
  #
  #   checkbox = Checkbox_Field.new(:name => :enable_me, 
  #                                 :value => :foo, 
  #                                 :label => 'Check me', 
  #                                 :options => [ :foo, :bar ] )
  #   form.add(checkbox)
  #
  # Modifying a field element *after* adding it to the 
  # form also works, as the form instance only references 
  # its form elements: 
  #
  #   checkbox.required = true 
  #
  # The all form instance this checkbox has been added to 
  # now recognize it as a required field. 
  #
  #   form.fields = [ :description, :enable_me ]
  #   form.delete_field(:enable_me)
  #
  # And this is something i personally really like: 
  #
  #   form[:description].required = true
  #
  # Now, checkbox is not included in the form's field 
  # configuration, but as it is a required field, it 
  # will be rendered as hidden field. 
  #
  #   puts form.to_s
  #
  # === Further customization
  #
  # The default form decorators (Form_Field_Wrapper and 
  # Form_Content_Wrapper) do their best to guess DOM ids 
  # and CSS classes. In case you want to implement your
  # own decorators - e.g. in case you don't want any 
  # 'guessed' CSS classes at all - you can overwrite them 
  # via 
  #
  #   the_form.field_decorator = My_Field_Decorator
  #
  # and
  #
  #   the_form.content_decorator = My_Content_Decorator
  #
  # See documentation to Form_Field_Wrapper and 
  # Form_Content_Wrapper for instructions on how to 
  # implement custom form decorators. 
  #
  class Form < Element

    # Array of form field names ordered by appearance in the form. 
    # It is used to determine which fields to render, and in which 
    # order. 
    attr_accessor :fields
    
    # Array of Form_Field instances includes in this form. 
    attr_accessor :elements
    
    # Hash mapping field names to Form_Field instances. 
    attr_accessor :element_map
    
    # Hash mapping form field names to their values. 
    attr_accessor :values 
    
    # Field decorator class to use for decorating single fields. 
    attr_accessor :field_decorator 
    
    # Decorator class to use for decorating the form content. 
    attr_accessor :content_decorator

    # Array of fieldsets in this form, ordered by appearance in 
    # the form. 
    attr_reader :fieldsets
  
    def initialize(params={}, &block)
      @fields        = params[:fields]
      @values        = params[:values]
      @fields      ||= []
      @elements      = []
      @element_map   = {}
      @fieldsets     = {}
      @values      ||= {}
      @title         = false
      @custom_fields = false
      @field_decorator   = Aurita::GUI::Form_Field_Wrapper
      @content_decorator = Aurita::GUI::Form_Content_Wrapper
      if block_given? then
        yield.each { |e| add(e) }
      end
      params.delete(:fields)
      params.delete(:values)
      params.delete(:title)
      params[:method]  = 'POST' unless params[:method]
      params[:enctype] = 'multipart/form-data' unless params[:enctype]
      params[:tag]     = 'form'
      params[:content] = content()
      params[:action]  = @action
      super(params)
    end

    # Returns field element map. 
    # An element map maps field names to elements of 
    # this form. 
    def attributes
      @element_map
    end

    # Access form element by index or name (by index if 
    # parameter is of type Numeric, by name otherwhise)
    def [](index)
      return @elements[index] if index.kind_of? Numeric
      return @element_map[index] if @element_map[index] 
      return @element_map[index.to_s] 
    end

    # Assign / overwrite field element with index form_index. 
    def []=(index, form_field)
      @content = false # Invalidate
      if !index.kind_of? Numeric
        delegated_to_fieldset = false
        @fieldsets.values.each { |fieldset|
          if fieldset.has_field?(index) then
            fieldset[index] = form_field
            delegated_to_fieldset = true
          end
        }
        
        @element_map[index.to_s] = form_field unless delegated_to_fieldset
        @elements.collect { |e|
          e = form_field if e.name.to_s == index.to_s
        }
      else 
        @elements[index] = form_field 
      end
    end
    
    # Delete form field with name field_name from 
    # this form. 
    def delete(field_name)
      @element_map.delete(field_name.to_s)
    end

    # Remove field with name=field_name from 
    # list of elements to be rendered in the form. 
    # The element will not be deleted from the form, 
    # so it can be enabled again using 
    #
    #   form.fields << :field_name
    #
    def delete_field(field_name)
      if field_name.kind_of? Numeric then
        index = field_name
        field = @fields.at(index)
        @elements[field.name.to_s] = nil
        @fields.delete_at(index)
      else
        field = @element_map[field_name.to_s]
        @fields.delete(field_name.to_s)
        @elements.delete(field)
      end
      @element_map.delete(field.name.to_s)
    end


    # Iterate over form field elements. 
    # This would add a CSS class to all elements without 
    # a value: 
    #
    #   form.each { |element| 
    #     element.class = 'missing' unless element.value
    #   }
    #
    def each(&block)
      @elements.each(&block)
    end

    # Add form field element to this form. 
    # TODO: Should overwrite previous field element 
    # with same field name. 
    def add(form_field_element)
      touch()
      if form_field_element.is_a?(Fieldset) then
        form_field_element.field_decorator   = @field_decorator
        form_field_element.content_decorator = @content_decorator
        @element_map.update(form_field_element.element_map)
        @elements  << form_field_element
        @fieldsets[form_field_element.name.to_s] = form_field_element
      else
        field_name = form_field_element.name.to_s
        form_field_element.value = @values[field_name] unless form_field_element.value.to_s != ''
        if !form_field_element.dom_id then
          form_field_element.dom_id = field_name.gsub('.','_')
        end
        delegated_to_fieldset = false
        @fieldsets.values.each { |fieldset|
          if fieldset.has_field?(field_name) then
            fieldset.add(form_field_element)
            delegated_to_fieldset = true
          end
        }
        @element_map[field_name] = form_field_element unless delegated_to_fieldset
        @elements    << form_field_element
      end
      @content = false # Invalidate
    end

    # Set field configuration. Form fields will be 
    # rendered in the same order as field names in the
    # parameter array. 
    # In case an element's field name is not included
    # in the array, it will not be rendered. 
    # Example: 
    #
    #   form.fields = [ :name, :description, :date ]
    #
    def fields=(attrib_array)
      touch()
      @custom_fields = true
      @fields = attrib_array.map { |field| 
        (field.is_a?(Hash))? field : field.to_s 
      }
      # Delegate fields to fieldsets first
      @fieldsets.each_pair { |name,fieldset|
        fieldset_fields = []
        @fields.delete_if { |field|
          (fieldset.has_field?(field))? (fieldset_fields << field.to_s; true) : false
        }
        fieldset.fields = fieldset_fields
      }
      attrib_array.each { |attrib|
        if attrib.is_a?(Hash) then
          attrib.each_pair { |fieldset_name, fieldset_fields|
            legend = false
            if fieldset_fields.is_a?(Hash) then
              legend = fieldset_fields[:legend]
              fieldset_fields = fieldset_fields[:fields]
            end
            # This is a configuration for a fieldset. 
            # There are two cases: 
            fieldset = @fieldsets[fieldset_name.to_s]
            if fieldset then 
              # - The fieldset already has been added to this form. 
              #   In this case, just pass field settings along to 
              #   the fieldset. 
              fieldset.fields = fieldset_fields
            else
              # - There is no fieldset with given name in this form. 
              #   In this case, we expect that at least the given 
              #   form fields are present in this form, and we 
              #   implicitly create a Fieldset instance here. 
              fieldset = Fieldset.new(:name => fieldset_name, :legend => legend)
              fieldset_fields.each { |field|
                existing_field = @element_map[field.to_s]
                fieldset.add(existing_field) if existing_field
              }
              fieldset.fields = fieldset_fields
              add(fieldset)
            end
          }
        end
      }
      @elements.each { |field|
        if field.is_a?(Form_Field) then
          # Update element map only if referenced element is a 
          # Form_Field, do not include Fieldset elements. 
          @element_map[field.name.to_s] = field 
        elsif field.is_a?(Fieldset) then
        end
      }
      @content = false # Invalidate
    end
    alias set_field_config fields=

    # Set field values for this form. 
    # Expects hash mapping field names to values. 
    # Example: 
    #   
    #   form.values = { :name => 'Foo', :description => 'Bar', :date => '20081012' }
    #
    def values=(value_hash={})
      touch()
      @values = value_hash
      @values.each_pair { |field_name, value|
        element = @element_map[field_name.to_s]
        element.value = value if element
      }
    end
    alias set_values values=

    # Return array of field names currently 
    # available for rendering. 
    def fields()
      if !@custom_fields || @fields.length == 0 then
        @elements.each { |field|
          if field.is_a?(Form_Field) then
            @fields << field.name
            @element_map[field.name.to_s] = field
          elsif field.is_a?(Fieldset) then
            @fields << { field.name => field.fields }
            @element_map.update(field.element_map)
          end
        }
      end
      @fields.uniq!
      return @fields
    end

    # Return underlying HTML element instance (HTML.ul), 
    # without wrapping HTML.form element. 
    def content
      @content = []
      if @title then
        @content << HTML.h1(:class => :form_title) { @title }
      end
      included_fields = []
      fields().each { |field|
        if field.is_a?(Hash) then
          # This is a fieldset
          field.each_pair { |fieldset_name, fieldset_fields|
            # Get Fieldset instance by name from @fieldsets: 
            @content << HTML.li { @fieldsets[fieldset_name.to_s] }
            if fieldset_fields.is_a?(Hash) then
              included_fields += fieldset_fields[:fields]
            else
              included_fields += fieldset_fields
            end
          }
        else 
          element = @element_map[field.to_s]
          if element then
            included_fields << element.name.to_s
            element = element.to_hidden_field() if element.hidden?
            if element.kind_of? Aurita::GUI::Hidden_Field then
              @content << element
            else
              @content << @field_decorator.new(element)
            end
          end
        end
      }
      included_fields = included_fields.map { |f| f.to_s }
      # Render required field as hidden field if not 
      # included in form field config: 
      @elements.each { |element| 
        if !included_fields.include?(element.name.to_s) && element.required? then
          @content << element.to_hidden_field()
        end
      }
      fields_id = dom_id().to_s+'_fields' if dom_id()
      @content = @content_decorator.new(:id => fields_id) { @content }
      return @content
    end

    # Render this form to an HTML.form instance. 
    # Wraps result of #content. 
    def element
      HTML.form(@attrib) { content() }
    end

    # Returns opening tag of this form instance. 
    # Useful for template helper methods. 
    # Example: 
    #
    #   form = Form.new(:action => 'where/to/send')
    #   puts form.header_string
    # -->
    #   '<form action="where/to/send" enctype="multipart/form-data" method="POST">'
    #
    def header_string
      HTML.form(@attrib).string.gsub('</form>','')
    end

    # Render this form to a string
    def string
      element().to_s
    end
    alias to_s string

    # Set all form elements to readonly mode. 
    def readonly! 
      elements.each { |e|
        e.readonly! 
      }
    end
    # Set all form elements to editable mode. 
    def editable! 
      elements.each { |e|
        e.editable! 
      }
    end

    # Set given fields to readonly. 
    # Example: 
    #
    #   form.set_readonly(:timestamp_changed, :timestamp_created
    #
    # Same as
    #
    #   form[:timestamp_changed].readonly!
    #   form[:timestamp_created].readonly!
    #  
    def set_readonly(*field_names)
      field_names.each { |field|
        @element_map[field.to_s].readonly!
      }
    end

  end

end
end
