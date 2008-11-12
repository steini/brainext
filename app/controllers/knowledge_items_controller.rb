class KnowledgeItemsController < ApplicationController
  
  before_filter :login_required, :except => [:show]
  
  history_skip :edit, :new

  def new
    @knowledge_item = KnowledgeItem.new()
  end

  def create
    
    @knowledge_item = KnowledgeItem.new(params[:knowledge_item])
    @knowledge_item.user = current_user
    
    if(@knowledge_item.save)
      redirect_to "/"
    else
      render :action => :new
    end
    
  end
  
  
  # TODO only search in public and own knowledge
  def search
    
    page = params[:page] || 1
    
    @search = Ultrasphinx::Search.new(
      :query => params[:q],
      :sort_mode => "descending",
      :sort_by => "created_at",
      :class_names => ["DeliciousBookmark", "KnowledgeItem"],
      :page => page
    )
    @search.run
    @search.results
    
    render :template => "knowledge_items/list"
  end
  
  def destroy
    @knowledge_item = KnowledgeItem.find(params[:id])
    
    raise "you are not allowed to delete this entry!" unless @knowledge_item.user_id == current_user.id
    
    @knowledge_item.destroy
    
    redirect_back
    
  end
  
  def edit
    @knowledge_item = KnowledgeItem.find(params[:id])
    
    raise "no permission to edit knowledge" unless @knowledge_item.user_id == current_user.id
    
    render :action => :new
  end
  
  def update
    
    @knowledge_item = KnowledgeItem.find(params[:id])
    
    raise "no permission to update knowledge" unless @knowledge_item.user_id == current_user.id
    
    if @knowledge_item.update_attributes(params[:knowledge_item])
      flash[:notice] = 'knowledge was successfully updated.'
      redirect_back
    else
      render :action => "edit"
    end
    
  end
  
  
  def show
  
    logged_in?
    
    @knowledge_item = KnowledgeItem.find(params[:id])
    
    # check for non public items and shield them
    if @knowledge_item.public == 0
      @knowledge_item.user_id == @current_user.id
      flash[:notice] = "Sorry, you don't have the permission to see this item!"
      @knowledge_item = nil
    end
    
  end
  
end
