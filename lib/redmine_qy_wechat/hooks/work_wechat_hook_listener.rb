class WorkWechatHookListener < Redmine::Hook::ViewListener
  render_on :view_account_login_bottom, :partial => "account/login_dingtalk"
  render_on :view_issues_show_details_bottom, :partial => "issues/dingtalk_flow"
end