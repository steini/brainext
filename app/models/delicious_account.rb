require 'open-uri'
require 'nokogiri'

class DeliciousAccount < ActiveRecord::Base
  
  belongs_to :user
  
  has_many :delicious_logs, :dependent => :destroy
  
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
  def fetch_bookmarks()
    
    new_bookmarks = 0
    fetched_bookmarks = 0
    unfetched_bookmarks = 0
    skipped_bookmarks = 0

    skipped_bookmark_ids = []
    
    delicious_log = DeliciousLog.new(
      :delicious_account_id => id,
      :started => Time.now
    )
    
    delicious_log.save
    
    puts "fetching #{TAGS_FETCH_URL % username}"
    
    doc = Nokogiri::XML(open(TAGS_FETCH_URL % username))

    puts "done"
    
    puts "processing tags"
    
    doc.xpath("/rss/channel/item/title").each do |title|
      
      tag = title.content
      
      puts "fetching bookmarks for #{tag} from #{BOKMARKS_BY_TAG_FETCH_URL % [username, tag]}"
      
      bookmarks_doc = Nokogiri::XML(open(BOKMARKS_BY_TAG_FETCH_URL % [username, tag]))
      
      bookmarks_doc.xpath("/rss/channel/item").each do |bookmark|
        
        guid =  bookmark.xpath("guid").first.content
        title =  bookmark.xpath("title").first.content
        link = bookmark.xpath("link").first.content
        categories = bookmark.xpath("category").map() { |category| category.content}
        
        bookmark = DeliciousBookmark.find_by_guid(guid)
        
        if bookmark.nil?
          
          new_bookmarks += 1
          
          bookmark = DeliciousBookmark.create(
            :guid => guid,
            :title => title,
            :link => link,
            :tag_list => categories.join(","),
            :delicious_account_id => id,
            :fetched => 0,
            :fetch_failures => 0
          )
        end
        
        # skip fetching when it was tried already
        # TODO define a Job that tries to fetch these
        if bookmark.fetch_failures >= 1
          # only count skipped bookmarks once
          unless skipped_bookmark_ids.include?(bookmark.id)
            skipped_bookmarks += 1 
            skipped_bookmark_ids << bookmark.id
          end
          next
        end
        
        begin
          unless bookmark.fetched
            bookmark.page_content 
            fetched_bookmarks += 1
            bookmark.update_attributes(
              "last_fetched" => Time.now
            )
          end
        rescue Exception => e
          puts "error fetching #{link}: #{e}"
          unfetched_bookmarks += 1
          bookmark.update_attributes(
            "last_fetched" => Time.now,
            "fetch_failures" => bookmark.fetch_failures + 1,
            "fetch_error" => e
          )
        end
        
      end
      
    end
    
    delicious_log.update_attributes(
      :imported => new_bookmarks,
      :skipped => skipped_bookmarks,
      :fetched => fetched_bookmarks,
      :unfetched => unfetched_bookmarks,
      :finished => Time.now
    )
    
  end
  
  def get_stats() 
    
    sql = "select count(fetched) as c, fetched from delicious_bookmarks " + 
      "where delicious_account_id = 1 GROUP BY fetched ORDER BY fetched DESC"
    
    result = DeliciousAccount.find_by_sql(sql)
    
    [0, 0] if result.length == 0 and return
    [result.first.c, result.last.c] 
  end
  
end
