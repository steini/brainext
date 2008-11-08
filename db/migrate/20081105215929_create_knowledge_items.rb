class CreateKnowledgeItems < ActiveRecord::Migration
  def self.up
    create_table :knowledge_items do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.boolean :public

      t.timestamps
    end
  end

  def self.down
    drop_table :knowledge_items
  end
end
