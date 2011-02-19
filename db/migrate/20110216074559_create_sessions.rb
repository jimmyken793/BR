class CreateSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.string :username
      t.string :password
      t.string :openid

      t.timestamps
    end
  end

  def self.down
    drop_table :sessions
  end
end
