class CreateDeliciousLogs < ActiveRecord::Migration
  def self.up
    create_table :delicious_logs do |t|
      t.integer :delicious_account_id
      t.integer :imported
      t.integer :fetched
      t.integer :unfetched
      t.integer :skipped
      t.datetime :started
      t.datetime :finished

      t.timestamps
    end
  end

  def self.down
    drop_table :delicious_logs
  end
end
