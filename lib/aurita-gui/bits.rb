
require('aurita-gui/element')

module Aurita
module GUI

  # Helper for img tag, assures tag attribute 
  # "alt" is set (for XHTML compliance). 
  # Could also be redefined in your application 
  # for some DHTML fancyness, so prefer using 
  # instances of Image over using HTML.img 
  # directly. 
  #
  class Image < Element

    def initialize(params={})
      params[:tag]     = :img
      params[:title] ||= params[:description]
      params[:alt]   ||= params[:title]
      params[:alt]   ||= params[:description]
      params[:alt]   ||= params[:src]
      super(params)
    end

  end

end
end
