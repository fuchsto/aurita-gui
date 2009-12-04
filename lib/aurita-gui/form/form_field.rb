
require('aurita-gui/element')
require('aurita-gui/html')
require('aurita-gui/form/form_error')

module Aurita
module GUI

  # Class Form_Field is an abstract base class for built-in
  # form fields (Input_Field, Hidden_Field, 
  # Radio_Field, Checkbox_Field, Select_Field, 
  # Textarea_Field) or any custom form field type. 
  # It is a wrapper for GUI::Element, extending it by
  # parameters @name, @label and @value. 
  #
  # Form_Field can be used directly as a decorator for any
  # instance of Element. 
  # This is useful in case you want to add GUI component
  # to a form that is not derived from Form_Field itself. 
  # To do so, pass an Element instance to the constructor's
  # block. 
  # Note that in any case, a Form_Field instance requires 
  # the :name attribute, even if this doesn't make 
  # sense at first glance when not adding a 'real' form
  # field. This is necessary as it could not be accessed 
  # after adding it to the form otherwise. 
  #
  # Example: 
  #
  #   button = Button.new(:onclick => 'submit();') { 'OK' }
  #   button_field = Form_Field.new(:name => :submit_button) { button }
  #   form.add(button_field)
  #
  #
  # In common cases, you won't use Form_Field directly, 
  # but one of it's derivates. 
  #
  # Usage: 
  #
  #   i = Input_Field.new(:name => :description, 
  #                       :label => 'Description', 
  #                       :value => 'Lorem ipsum dolor')
  #
  # Apart from this special attributes, Form_Field instances
  # behave like any GUI::Element: 
  #
  #   i.onclick = "alert('i have been clicked');"
  #   i.class   = 'css_class'
  #
  # To indicate a required form field, set the :required flag: 
  #
  #   i = Input_Field.new(:required => true, :name => :description)
  #
  # Or
  #
  #   i.required = true
  #
  # A required field will always be rendered, even 
  # if it is not included in the form field settings. 
  # In this case, it is rendered as hidden field. 
  #
  # To force rendering a form element as hidden field, 
  # set the :hidden flag: 
  #
  #   i = Input_Field.new(:hidden => true, :name => :hide_me)
  #
  # Or
  #
  #   i.hidden = true
  #
  # There is also a readonly render mode for form fields 
  # In readonly mode, a field element will be rendered as 
  # div element, containing the field value. 
  # This is useful for delete forms. 
  #
  #   i = Input_Field.new(:readonly => true, :name => :description)
  #
  # Or
  #
  #   i.readonly = true # or i.readonly! 
  #
  # And back to editable render mode: 
  #
  #   i.redonly = false 
  #
  # Or 
  #
  #   i.editable! 
  #
  # You can also store an expected data type in an Form_Field. 
  # This is just for convenience for e.g. form generators. 
  # So far, Form_Field@data_type won't be interpreted by 
  # any part of Aurita::GUI. 
  #
  class Form_Field < Element

    attr_accessor :type, :form, :label, :value, :required, :hidden, :data_type, :invalid, :hint

    def initialize(params, &block)
      # @value  = params[:value]
      raise Form_Error.new('Must provide parameter :name for ' << self.class.to_s) unless params[:name]
      @form      = params[:parent]
      @form    ||= params[:form]
      @label     = params[:label]
      # Get value from params unless set by derived constructor: 
      @value     = params[:value] unless @value 
      @required  = params[:required]
      @hidden    = params[:hidden]
      @data_type = params[:data_type]
      @invalid   = params[:invalid]
      @hint      = params[:hint]
      # Do not delete parameter value, as it is a 
      # standard for <input> elements. 
      # Field types not supporting the value attribute
      # (Textarea_Field, Option_Field, ...)
      # must delete it themselves. 
      @readonly = false
      params.delete(:form)
      params.delete(:parent)
      params.delete(:label)
      params.delete(:required)
      params.delete(:hidden)
      params.delete(:data_type)
      params.delete(:invalid)
      params.delete(:hint)
      params[:parent] = @form
      if block_given? then 
        @element = yield
        params[:content] = @element
      end
      super(params)
    end

    # Virtual method. 
    def element
      raise Form_Error.new('Form_Field@element not set for ' << self.inspect) unless @element
      @element
    end

    # Render this form field element to a 
    # readonly element. 
    # Will not affect this element instance. 
    def readonly_element
      # Todo: Add CSS classes 'readonly' and self.class
      HTML.div(@attrib) { @value }
    end

    # Render this form field element to a 
    # Hidden_Field instance. Will not affect 
    # this element instance. 
    def to_hidden_field
      Hidden_Field.new(:type  => :hidden, 
                       :name  => @attrib[:name], 
                       :id    => dom_id.to_s, 
                       :value => @value)
    end

    # Render this form field element to string. 
    def to_s
      return element().to_s unless @readonly
      return readonly_element().to_s
    end
    alias string to_s

    # Set field element to editable mode. 
    # See Aurita::GUI::Form for more information 
    # on rendering modes. 
    def editable!
      @readonly = false
      remove_class(:readonly)
    end

    # Set field element to readonly mode. 
    # See Aurita::GUI::Form for more information 
    # on rendering modes. 
    def readonly!
      @readonly = true
      add_class(:readonly)
    end
    # Whether this field element is in readonly mode. 
    def readonly? 
      @readonly
    end
    # Set :readonly flag (true | false). 
    def readonly=(is_readonly)
      @readonly = is_readonly
      if is_readonly then 
        add_class(:readonly) 
      else 
        remove_class(:readonly) 
      end
    end

    # Mark field element as invalid (e.g. missing value). 
    def invalid!
      @invalid = true
      add_class(:invalid)
    end
    # Whether this field element is marked as invalid. 
    def invalid? 
      @invalid == true
    end
    # Set :invalid flag (true | false). 
    def invalid=(is_invalid)
      @invalid = is_invalid
      if is_invalid then 
        add_class(:invalid) 
      else 
        remove_class(:invalid) 
      end
    end

    # Set field element to disabled mode. 
    # See Aurita::GUI::Form for more information 
    # on rendering modes. 
    def disable! 
      @attrib[:disabled] = true
      add_class(:disabled)
    end
    # Set field element to enabled mode (default).
    # See Aurita::GUI::Form for more information 
    # on rendering modes. 
    def enable! 
      @attrib.delete(:disabled)
      remove_class(:disabled)
    end
    def disabled=(is_disabled)
      @disabled = is_disabled
      if is_disabled then 
        add_class(:disabled) 
      else 
        remove_class(:disabled) 
      end
    end

    # Set :required flag (true | false). 
    def required=(is_required)
      @required = is_required
      if is_required then 
        add_class(:required) 
      else 
        remove_class(:required) 
      end
    end

    # Set field element to required mode. 
    # See Aurita::GUI::Form for more information 
    # on rendering modes. 
    def required!
      @required = true
      add_class(:required)
    end
    # Set field element to optional mode (default). 
    def optional!
      @required = false
      remove_class(:required)
    end
    # Whether this field element is a required field. 
    def required?
      (@required == true)
    end

    # Set hidden flag for this element. 
    # See Aurita::GUI::Form for more information 
    # on rendering modes. 
    def hide!
      @hidden = true
    end
    # Remove :hidden flag from this element. 
    def show!
      @hidden = false
    end
    # Whether this field element is hidden. 
    def hidden?
      (@hidden == true)
    end

  end # class


end # module
end # module
