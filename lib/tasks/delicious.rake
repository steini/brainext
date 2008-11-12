namespace "delicious" do
  desc "import the delecious bookmarks for our users"
  task :import => :environment do
    
    RAILS_DEFAULT_LOGGER.silence do
      accounts = DeliciousAccount.find(:all)
    
      accounts.each do |account|
        account.fetch_bookmarks
      end
    end
  end
  
  desc "clean download dir and db"
  task :clear => :environment do
    
    bookmarks = DeliciousBookmark.find(:all)
    
    bookmarks.each do |bookmark|
      bookmark.destroy
    end
    
    DeliciousLog.find(:all).each{ |log| log.destroy }
    
  end
  
  desc "index the delicious bookmarks"
  task :index => :environment do
    
    bookmarks = DeliciousBookmark.find(:all, :conditions => ["fetched = ?", 1], :group => "link")
    
    puts "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    puts "<sphinx:docset>"
    puts "<sphinx:schema>"
    puts "<sphinx:field name=\"title\"/>"
    puts "<sphinx:field name=\"body\"/>"
    puts "<sphinx:field name=\"class\"/>"
    puts "<sphinx:attr name=\"class_id\" type=\"int\"/>"
    puts "<sphinx:attr name=\"created_at\" type=\"timestamp\"/>"
    puts "</sphinx:schema>"
    
    bookmarks.each do |bookmark|
      puts("<sphinx:document id=\"#{bookmark.id * 2}\">")
      puts("<class_id>0</class_id>")
      puts("<class>DeliciousBookmark</class>")
      puts("<title><![CDATA[[#{bookmark.title}]]></title>")
      puts("<body><![CDATA[[#{bookmark.page_content}]]></body>")
      puts("<created_at>#{bookmark.created_at}</created_at>")
      puts("</sphinx:document>")
    end

    
    #    puts("<sphinx:document id=\"1\">")
    #    puts("<class_id>0</class_id>")
    #    puts("<class>DeliciousBookmark</class>")
    #    puts("<title><![CDATA[[title]]></title>")
    #    puts("<body><![CDATA[[#{File.read("/home/steini/NetBeansProjects/brainext/tmp/data/delicious/119")}]]></body>")
    #    puts("<created_at>12.10.2009</created_at>")
    #    puts("</sphinx:document>")
    
    puts "</sphinx:docset>"
    
  end
end