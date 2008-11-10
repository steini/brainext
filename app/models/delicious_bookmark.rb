require 'net/http'

class DeliciousBookmark < ActiveRecord::Base
  
  acts_as_taggable
  
  belongs_to :delicious_account
  
  def index
   
    
  end
  
end
