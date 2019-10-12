class AddCorpWechatAccountNumberToUsers < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :users, :corp_wechat_account_number, :string
  end
end
