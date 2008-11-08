class KnowledgeItemsController < ApplicationController
  
  before_filter :login_required
  
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
    
    @search = Ultrasphinx::Search.new(
      :query => params[:q],
      :sort_mode => "descending",
      :sort_by => "created_at"
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
  
end
