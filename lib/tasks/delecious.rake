namespace "delicious" do
  desc "import the delecious bookmarks for our users"
  task :import => :environment do
    
    accounts = DeliciousAccount.find(:all)
    
    accounts.each do |account|
      account.fetch_bookmarks
    end
  end
  
  desc "index the delicious bookmarks"
  task :index => :environment do
    
    bookmarks = DeliciousBookmark.find(:all, :group => "link")
    
    bookmarks.each do |bookmark|
      bookmark.index
    end
    
  end
end