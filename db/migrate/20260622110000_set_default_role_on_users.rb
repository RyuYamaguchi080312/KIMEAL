class SetDefaultRoleOnUsers < ActiveRecord::Migration[8.0]
  def up
    change_column_default :users, :role, from: nil, to: 0
    execute "UPDATE users SET role = 0 WHERE role IS NULL"
  end

  def down
    change_column_default :users, :role, from: 0, to: nil
  end
end
