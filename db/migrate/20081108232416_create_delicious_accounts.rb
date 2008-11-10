class CreateDeliciousAccounts < ActiveRecord::Migration
  def self.up
    create_table :delicious_accounts do |t|
      
      t.integer :user_id
      t.string :username
      
      t.timestamps
    end
  end

  def self.down
    drop_table :delicious_accounts
  end
end
