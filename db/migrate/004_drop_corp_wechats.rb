class DropCorpWechats  < Rails.version < '5.1' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def drop
    drop_table :corp_wechats
  end
end
