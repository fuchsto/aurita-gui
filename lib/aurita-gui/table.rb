
require('aurita-gui/html')

module Aurita
module GUI


  # Usage: 
  #
  #   table = Table.new(:headers => [ 'user', 'phone', 'mobile', 'email' ])
  #   table.add_row('fuchsto', '+49 89 123456', '+49 89 987654', 'fuchs@wortundform.de')
  #
  # A row element may be of type Aurita::GUI::Element. 
  # In this case, method #string is invoked to render the cell. 
  #
  # More examples: 
  #
  #   t = Table.new(:headers => ['user', 'phone', 'email'], 
  #                 :class => 'css_class', 
  #                 :id => 'test_table' )
  #   t.add_row('a','b','c' )
  #
  #   t[0].class == Table_Cell
  #   t[0][0].value = 'foo'
  #   t[0][0].value = 45
  #   t[1][0].onclick = 'test();'
  #   t[0][1] = HTML.a(:href => 'http://google.com') { 'google' }
  #
  #   t[0][1].value.href = 'other'
  #   t[0][1].value.content = 'clickme'
  #
  #   puts t[0][1].value.string
  #
  #   t[0].class = 'highlighted'
  #
  class Table < Element

    attr_accessor :columns, :headers, :rows, :template, :row_css_classes, :column_css_classes, :row_class, :row_css_class_seq, :decorators

    def initialize(params={}, &block)
      params[:tag]   = :table
      @headers     ||= params[:headers]
      @num_columns ||= params[:num_columns]
      @num_columns ||= @headers.length if @headers.is_a?(Array)
      @num_columns ||= 1
      @columns     ||= []
      @rows        ||= []
      @headers     ||= []
      @row_class   ||= params[:row_class]
      @row_class   ||= Table_Row
      @row_css_classes      = params[:row_css_classes]
      @row_css_classes    ||= []
      @row_css_classes      = [ @row_css_classes ] unless @row_css_classes.is_a?(Array)
      @row_css_class_seq    = params[:row_css_class_seq]
      @row_css_class_seq  ||= []
      @row_css_class_seq    = [ @row_css_class_seq ] unless @row_css_class_seq.is_a?(Array)
      @column_css_classes   = params[:column_css_classes]
      @column_css_classes ||= []
      @column_css_classes   = [ @column_css_classes ] unless @column_css_classes.is_a?(Array)
      @decorators         ||= {}
      params[:cellpadding]  = 0 unless params[:cellpadding]
      params[:cellspacing]  = 0 unless params[:cellspacing]
      params.delete(:headers)
      params.delete(:num_columns)
      params.delete(:row_css_classes)
      params.delete(:row_css_class_seq)
      params.delete(:column_css_classes)
      set_headers(@headers)

      if block_given? then
        content = yield
        if content.is_a?(Array) then
          super(params)
          content.each { |c| add_row(c) }
        else
          super(params, &block)
        end
      else
        super(params)
      end
    end

    def decorate(column_index, &block)
      @decorators[column_index] = block
    end

    def headers=(*headers)
      @headers = headers
      @headers = headers.first if headers.is_a?(Array)
      if @headers.length > 0 then
        @headers.map! { |cell| 
          if cell.is_a? Element then 
            cell 
          else 
            HTML.th { cell } 
          end 
        }  
      end
    end
    alias set_headers headers=

    def column_css_classes=(*classes)
      @column_css_classes = classes
      @column_css_classes.flatten! 
   #  touch()
    end
    alias set_column_css_classes column_css_classes=

    def add_row(*row_data)
      if row_data.first.is_a?(Array) || row_data.first.is_a?(Table_Row) then
        row_data = row_data.first
      end
      row = row_data
      
      if !row.respond_to?(:string) then
        row = @row_class.new(row_data, :parent => self)
      else 
        row.parent = self
      end
      @rows << row

      # Add row content to columns
      row_index = 0
      @columns.each { |c|
        c.add[row[row_index]]
        row_index += 1
      }
    end

    def <<(row)
      add_row(*row)
    end

    def string
      t = []
      if @headers.length > 0 then
        t = HTML.tr { @headers.collect { |cell| if cell.is_a? Element then cell else HTML.th { cell } end } }  
      end
      body_id = "#{@attrib[:id]}_body" if @attrib[:id]
      t += HTML.tbody(:id => body_id) { rows() }
      set_content(t)
      super()
    end
    alias to_s string

    def set_column_decorator(column_index, decorator)
    end

    def set_data(row_array)
      @rows = []
      row_array.each { |row|
        @rows << @row_class.new(row, :parent => self)
      }
    end

    # Returns cell at given column and row (like x, y coordinates)
    def cell(column, row)
      rows[row][column]
    end

    # Returns Table_Row instance at given row index in table. 
    def [](row_index)
      rows[row_index]
    end

    # Sets Table_Row instance at given row index in table. 
    def []=(row_index, row_data)
      rows[row_index] = row_data
    end

    def columns
      Table_Column.new(@columns)
    end

  end

  class Table_Row < Element
    
    attr_accessor :cells, :parent

    def initialize(*args, &block)

      if args[0].is_a?(Hash) then
        params    = args[0]
      end

      if block_given? then
        cell_data = yield
      elsif args[0].is_a?(Array) then
        cell_data = args[0]
        params    = args[1]
      end
      
      params  ||= {}
      params[:tag]  = :tr

      @parent     ||= params[:parent]
      @cell_class ||= Table_Cell
      @cell_data  ||= cell_data
      @cells      ||= []
      @touched      = false
      column_index  = 0

      @cell_data.each { |cell|
        if !cell.kind_of?(Table_Cell) then
          cell = @cell_class.new(cell, :parent => self, :column_index => column_index)
        end
        @cells << cell
        column_index += 1
      }
      set_content(@cells)
      @content = @cells

      super(params)
      add_css_classes(@parent.row_css_classes) if @parent && @parent.row_css_classes.length > 0
    end
    
    def table
      @parent
    end
    
    def [](column_index)
      @cells[column_index]
    end
    def []=(column_index, cell_data)
      @cells[column_index].value = cell_data
      touch()
    end
    
    def string
      if touched? then
        @cells = []
        @cell_data.each { |cell|
          @cells << @cell_class.new(cell, :parent => self, :column_index => column_index)
          column_index += 1
        }
        set_content(@cells)
        @touched = false
      end
      super()
    end

    def inspect
      "#{self.class}[" << @cells.collect { |c| c.inspect }.join(',') + ']'
    end
  end

  # Virtual Element: There is no mapped HTML element
  # for table columns. 
  class Table_Column 
    def initialize(cell_array)
      @cells = cell_array
    end
    def [](row_index)
      @cells[row_index]
    end
    def []=(row_index, cell_element)
      @cells[row_index] = cell_element
    end
  end

  # Accessor for a table cell. 
  # Usage: 
  #
  #   cell = my_table[row][column]
  #   cell.content = 'New cell content'
  #   cell.class   = 'table_cell_css_class'
  #
  class Table_Cell < Element

    attr_accessor :value, :presentation_class, :parent

    def initialize(cell_element, params={})
      params[:tag]          = :td
      @parent             ||= params[:parent]
      @decorator            = @parent.parent.decorators[@column_index] if @parent.parent.respond_to?(:decorators)
      @decorator          ||= false
      @content            ||= cell_element
      @value              ||= cell_element
      @presentation_class ||= false
      @column_index         = params[:column_index]
      params.delete(:column_index)
      super(params)
      column_css_classes = @parent.parent.column_css_classes[@column_index] if @parent.parent
      add_css_classes(column_css_classes) if column_css_classes
    end
    
    def set_presentation(presentation_class)
      @presentation_class = presentation_class
    end
    alias presentation= set_presentation

    def value=(val)
      @value = val
      @value = @decorator.call(@value) if @decorator
      set_content(@value) unless @presentation_class
      set_content(@presentation_class.new(@value)) if @presentation_class
      touch()
    end

    def inspect
      "#{self.class}[#{value.inspect}]"
    end

  end

end
end

