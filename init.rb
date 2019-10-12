Redmine::Plugin.register :redmine_work_wechat do
  name 'Redmine Work Wechat & Dingtalk plugin'
  author 'Tigergm and Tecsoon team'
  description 'This is a plugin of Work Wechat and Dingtalk for Redmine'
  version '0.2.7'
  url 'https://bitbucket.org/39648421/redmine_work_wechat'
  author_url 'https://bitbucket.org/39648421'
  
  permission :corp_wechats, { :corp_wechats => [:new] }, :public => true
  menu :admin_menu, :corp_wechats, {:controller => 'settings', :action => 'plugin', :id => "redmine_work_wechat"},:caption => :menu_qy_wechats
                      
  settings :default => {
  }, :partial => 'settings/corp_wechat'
                      
  # Redmine::Search.map do |search|
  #   search.register :corp_wechats
  # end
end
require 'redmine_qy_wechat'