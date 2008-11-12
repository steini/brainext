class KnowledgeItem < ActiveRecord::Base

  belongs_to :user
  
  validates_presence_of :title, :body, :user
  
  is_indexed :fields => ['title', 'body', 'created_at']

  acts_as_taggable
  
end
