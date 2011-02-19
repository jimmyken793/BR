class RenameOpenidField < ActiveRecord::Migration
  def self.up
    rename_column("users","openid","open_id");
  end

  def self.down
    rename_column("users","open_id","openid");
  end
end
