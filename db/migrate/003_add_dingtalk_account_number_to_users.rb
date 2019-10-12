class AddDingtalkAccountNumberToUsers  < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :users, :dingtalk_account_number, :string
  end
end
