class AddFieldsToDeliciousBookmark < ActiveRecord::Migration
  def self.up
    add_column :delicious_bookmarks, :last_fetched, :datetime
    add_column :delicious_bookmarks, :fetch_failures, :integer
    add_column :delicious_bookmarks, :fetch_error, :text
  end

  def self.down
    remove_column :delicious_bookmarks, :last_fetched
    remove_column :delicious_bookmarks, :fetch_failures
    remove_column :delicious_bookmarks, :fetch_error
  end
end
