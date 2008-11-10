class CreateDeliciousBookmarks < ActiveRecord::Migration
  def self.up
    create_table :delicious_bookmarks do |t|
      t.string :guid
      t.string :title
      t.boolean :fetched
      t.string :link
      t.integer :delicious_account_id
      t.text :content
      t.timestamps
    end
  end

  def self.down
    drop_table :delicious_bookmarks
  end
end
