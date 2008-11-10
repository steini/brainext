require 'open-uri'
require 'nokogiri'

class DeliciousAccount < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :delicious_bookmarks
  
  TAGS_FETCH_URL = "http://feeds.delicious.com/v2/xml/tags/%s"
  BOKMARKS_BY_TAG_FETCH_URL = "http://feeds.delicious.com/v2/xml/%s/%s?count=100"
  
  
  BUFFER_SIZE = 102400
  
  #
  # fetch all bookmarks from delicious and store them in our db.
  # 
  # because the fetch is limited to 100 entries, we are fetching the
  # tags and for each tag the bookmarks
  #
  def fetch_bookmarks
    
    puts "fetching #{TAGS_FETCH_URL % username}"
    
    doc = Nokogiri::XML(open(TAGS_FETCH_URL % username))

    puts "done"
    
    puts "processing tags"
    doc.xpath("/rss/channel/item/title").each do |title|
      
      tag = title.content
      
      puts "fetching bookmarks for #{tag} from #{BOKMARKS_BY_TAG_FETCH_URL % [username, tag]}"
      
      bookmarks_doc = Nokogiri::XML(open(BOKMARKS_BY_TAG_FETCH_URL % [username, tag]))
      
      bookmarks_doc.xpath("/rss/channel/item").each do |bookmark|
        
        puts "processing bookmark #{bookmark}"
        
        guid =  bookmark.xpath("guid").first.content
        title =  bookmark.xpath("title").first.content
        link = bookmark.xpath("link").first.content
        categories = bookmark.xpath("category").map() { |category| category.content}
        
        fetch_bookmark(guid, title, link, categories)
      end
      
    end
    
  end
  
  def fetch_bookmark(guid, title, link, categories)
    
    bookmark = DeliciousBookmark.find_by_guid(guid)
    
    if bookmark.nil?
      bookmark = DeliciousBookmark.new(
        :guid => guid,
        :title => title,
        :link => link,
        :tag_list => categories.join(","),
        :delicious_account_id => id,
        :fetched => 0
      )
      bookmark.save
        
      begin
        bookmark.update_attributes(
          :fetched => 1,
          :content => fetch_page(link)
        )
      rescue Exception => e
        puts e
      end
      
    end
  end
  
  def fetch_page(link)
    pieces = URI.parse(link)
    Net::HTTP::start(pieces.host, pieces.port) do |connection|
      response = connection.request_get(pieces.path)
      response.body
    end   
    
  end
  
end
