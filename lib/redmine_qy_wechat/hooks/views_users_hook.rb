module RedmineQyWechat
    module Hooks
        class ViewsUsersHook < Redmine::Hook::ViewListener
            # 用户添加企业微信
            def view_users_form(context={})
              corp_wechat_account_number_options(context)
            end
            # 个人账户添加企业微信
            def view_my_account(context={})
              corp_wechat_account_number_options(context)
            end
            # 人员管理添加企业微信
            def view_people_form(context={})
              corp_wechat_account_number_options(context)
            end
            def corp_wechat_account_number_options(context)
              user  = context[:user]
              f     = context[:form]
              s     = ''
                
              # List all the landing pages after login.
              # 1) Issue List of a project
              # 2) Custom Query Issue List.
              # 3) My Page
             
        
              s << "<p>"
              s << label_tag( "user_corp_wechat_account_number", l(:user_qy_wechat_account_number))
              if user && user.corp_wechat_account_number
                  s << text_field_tag( 'user[corp_wechat_account_number]',user.corp_wechat_account_number)
              else
                  
                  s << text_field_tag( 'user[corp_wechat_account_number]',nil)
              end
              s << "</p>"
              
              if user && User.current.admin?
                  s << "<p>"
                  s << label_tag( "user_dingtalk_account_number", l(:user_dingtalk_account_number))
                  s << text_field_tag( 'user[dingtalk_account_number]',user.dingtalk_account_number)
                  s << "</p>"
              end
              
              s << "<p>"
              s << label_tag( "user_dingtalk_dingid", l(:user_dingtalk_dingid))
              if user && user.dingtalk_dingid
                  s << text_field_tag( 'user[dingtalk_dingid]',user.dingtalk_dingid)
              else
                  
                  s << text_field_tag( 'user[dingtalk_dingid]',nil)
              end
              s << "</p>"
              return s.html_safe
            end
            
        end
    end
end