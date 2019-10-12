# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
  # dingtalk router
  get 'issues/:id/dingtalk_flow', :to => 'dingtalk#start_dingtalk_flow', :as => 'start_dingtalk_flow'
