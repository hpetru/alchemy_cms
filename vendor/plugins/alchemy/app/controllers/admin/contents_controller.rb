class Admin::ContentsController < ApplicationController
  
  layout 'admin'
  
  filter_access_to :all
  
  def new
    @element = Element.find(params[:element_id])
    @atoms = @element.available_atoms
    @content = @element.contents.build
    render :layout => false
  end
  
  def create
    begin
      @element = Element.find(params[:content][:element_id])
      @content = Content.create_from_scratch(@element, params[:content])
      @options = params[:options]
      # If options params come from Flash uploader then we have to parse them as hash.
      if @options.is_a?(String)
        @options = Rack::Utils.parse_query(@options)
      end
      if @content.essence_type == "EssencePicture"
        atoms_of_this_type = @element.contents.find_all_by_essence_type('EssencePicture')
        @dragable = atoms_of_this_type.length > 1
        @options = @options.merge(
          :dragable => @dragable
        )
        unless params[:image_id].blank?
          @content.essence.image_id = params[:image_id]
          @content.essence.save
        end
      end
    rescue Exception => e
      logger.error(e)
      logger.error(e.backtrace.join("\n"))
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("atom_not_successfully_added"), :error)
      end
    end
  end
  
  def update
    atom = Content.find(params[:id])
    atom.atom.update_attributes(params[:atom])
    render :update do |page|
      page << "alchemy_window.close();reloadPreview()"
    end
  end
  
  def order
    element = Element.find(params[:element_id])
    for content_id in params["element_#{element.id}_contents"]
      content = Content.find(content_id)
      content.move_to_bottom
    end
    render :update do |page|
      Alchemy::Notice.show_via_ajax(page, _("Successfully saved content position"))
      page << "reloadPreview()"
    end
  end
  
  def destroy
    begin
      atom = Content.find(params[:id])
      element = atom.element
      atom_name = atom.name
      content_dom_id = "#{atom.essence_type.underscore}_#{atom.id}"
      if atom.destroy
        render :update do |page|
          page.remove(content_dom_id)
          Alchemy::Notice.show_via_ajax(page, _("Successfully deleted %{atom}") % {:atom => atom_name})
          page << "reloadPreview()"
        end
      end
    rescue
      log_error($!)
      render :update do |page|
        Alchemy::Notice.show_via_ajax(page, _("atom_not_successfully_deleted"), :error)
      end
    end
  end
  
end
