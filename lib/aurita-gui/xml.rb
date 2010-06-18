
require('aurita-gui/xml/xml_element')


module Aurita
module GUI

  class XML

    def self.render(meth_name, *args, &block)
      raise ::Exception.new('Missing attributes for XML.' << meth_name.inspect) unless args
      e = XML_Element.new(*args, &block)
      e.tag = meth_name
      e
    end

    def self.build(&block)
      raise ::Exception.new('Missing block for XML.render') unless block_given?
      XML_Element.new(:tag => :pseudo) { self.class_eval(&block) }
    end
    
    # p is defined in Kernel, so we have to 
    # redirect it manually (method_missing won't be 
    # triggered for it)
    def self.p(*attribs, &block)
      render(:p, *attribs, &block)
    end

    def self.method_missing(meth_name, *attribs, &block)
      render(meth_name, *attribs, &block) 
    end
    def method_missing(meth_name, *attribs, &block)
      self.class.render(meth_name, *attribs, &block) 
    end

    # A builder for XML documents. 
    # Example: 
    #
    #
    #    xmldoc = XML::Document.new(:encoding => 'utf-8') { |x|
    #       x.og.page { 
    #         x.og.title { 'Page title' } + 
    #         x.og.images { 
    #           images.map { |i| x.og.image { i } }
    #         }
    #       }
    #    }
    #
    #    xmldoc.to_s
    #    
    #  -->
    #
    #    <?xml version="1.0" encoding="utf-8" ?>
    #    <og:page>
    #      <og:title>Page title</og:title>
    #      <og:images>
    #         <og:image>http://domain.com/image1.jpg</og:image>
    #         <og:image>http://domain.com/image2.jpg</og:image>
    #         <og:image>http://domain.com/image3.jpg</og:image>
    #      </og:images>
    #    <og:page>
    #
    class Document

      attr_accessor :content

      def initialize(params={}, &block)
        @params  = params
        @params[:version]  ||= '1.0'
        @params[:encoding] ||= 'UTF-8'
        @content = yield(XML.new)
      end

      def string
        params = ''
        @params.each_pair { |k,v|
          params << "#{k}=\"#{v}\" "
        }
        "<?xml #{params} ?>\n#{@content.to_s}"
      end
      alias to_s string
      alias to_str string

    end

  end # class


end
end

