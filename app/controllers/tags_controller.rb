class TagsController < ApplicationController
  def tagged_with

    page = params[:page] || 1
    
    @tag = Tag.find_by_name(params[:tag])
    
    @tagged_items = Tagging.paginate_by_tag_id(@tag.id, :page => page, :include => :taggable)
  end

end
