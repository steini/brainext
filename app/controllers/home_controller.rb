class HomeController < ApplicationController

  def index
    @knowledge_items = KnowledgeItem.find(:all, :conditions => ["public = ? or user_id = ?", 1, current_user || -1], :order => "created_at DESC", :limit => 10)
  end

  
end
