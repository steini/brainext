class RenameContentColumnInDeliciousBookmark < ActiveRecord::Migration
  def self.up
    add_column :delicious_bookmarks, :body, :text
    remove_column :delicious_bookmarks, :content
  end

  def self.down
    add_column :delicious_bookmarks, :content, :text
    remove_column :delicious_bookmarks, :body
  end
end
