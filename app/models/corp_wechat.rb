class CorpWechat < ActiveRecord::Base
  unloadable
  validates_presence_of :corp_id,:corp_secret,:app_name,:corp_name
  validates :app_id, presence: true, uniqueness: true
end
