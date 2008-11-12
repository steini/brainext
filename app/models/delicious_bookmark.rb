require 'net/http'

class DeliciousBookmark < ActiveRecord::Base
  
  include ActionView::Helpers::SanitizeHelper
  
  DELICIOUS_DATA_DIR = "#{RAILS_ROOT}/tmp/data/delicious/"
  
  acts_as_taggable
  
  belongs_to :delicious_account
  
  is_indexed :fields => ['title', 'body', 'created_at']
  
  def strip_html(content)
    content = strip_tags(content)
    content = sanitize(content)
    #.gsub("\n", "").gsub("\t", "")
    content.gsub("\n", "").gsub("\t", "").gsub("<", "").gsub(">", "")
  end
  
  def page_content()

    content_file = "#{DELICIOUS_DATA_DIR}/#{id}"
    
    if body.nil?
      
      content = ""
      
      pieces = URI.parse(link)
      Net::HTTP::start(pieces.host, pieces.port) do |connection|
        response = connection.request_get(pieces.path)
        content = response.body
      end
      
      FileUtils.makedirs(DELICIOUS_DATA_DIR) unless File.exists?(DELICIOUS_DATA_DIR)
      
      File.open(content_file, "w") do |f|
        f.write(strip_html(content))
      end
      
      #puts "converting #{content_file} to utf-8"
      #`iconv -t utf-8 #{content_file} -c > #{content_file}`
      
      puts "storing content of #{content_file} to db"
      body = File.read(content_file)

      
      update_attributes(
        :body => body,
        :fetched => 1
      )
      
      puts "deleting file #{content_file}"
      File.delete(content_file)
      #puts "downloaded content from #{link} and wrote it to #{content_file} (#{content.length})"
      puts "done"
    end
    #puts "reading content from file #{content_file}"
  end
end
