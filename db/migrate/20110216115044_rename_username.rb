class RenameUsername < ActiveRecord::Migration
  def self.up
    rename_column("users","username","login");
  end

  def self.down
    rename_column("users","login","username");
  end
end
