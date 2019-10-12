module RedmineQyWechat
  module Patches
    # Requires openssl and base64.
    require 'openssl'
    require "base64"
    module AccountControllerPatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          # defind a globle var for backurl
          # 适配4.0 
          alias_method :login_without_login_dingtalk, :login
          alias_method :login, :login_with_login_dingtalk
          alias_method :successful_authentication_without_login_dingtalk, :successful_authentication
          alias_method :successful_authentication, :successful_authentication_with_login_dingtalk
        end
      end
    
      module InstanceMethods
        def login_with_login_dingtalk
          logger.info("redmine_work_wechat login ------------------------------")
          auth_code = params[:auth_code]
          logger.info("auth_code:#{auth_code}")
          if auth_code.blank?
            code = params[:code]
            state = params[:state]            
            # 如果是钉钉登录回调
            if state == "STATE"
              appid = Setting["plugin_redmine_work_wechat"]["dingtalk_login_appid"]
              appsecret = Setting["plugin_redmine_work_wechat"]["dingtalk_login_appsecret"]
              redirect_url = Setting["plugin_redmine_work_wechat"]["dingtalk_login_redirect"]
              # logger.info(appid)
              # logger.info(appsecret)
              # logger.info(redirect_url)
              if (appid.blank? || appsecret.blank? || redirect_url.blank?)
                return
              end
            
              begin
              timestamp = (Time.now.to_f * 1000).to_i
              logger.info("timestamp:#{timestamp}")

              key = appsecret

              # key = "testappSecret"
              # timestamp = "1546084445901"

              hash  = OpenSSL::HMAC.digest("sha256", key, timestamp.to_s).strip
              # logger.info(hash)
              hash = Base64.encode64(hash).strip
              # logger.info(hash)
              signature = ERB::Util.url_encode(hash).strip
              # logger.info(signature)

              data ={
                 "tmp_auth_code": code
              }.to_json

              url = URI.parse("https://oapi.dingtalk.com/sns/getuserinfo_bycode?accessKey=#{appid}&timestamp=#{timestamp}&signature=#{signature}")
              http = Net::HTTP.new(url.host,url.port)
              http.use_ssl = true
              
              # logger.info("url.request_uri")
              # logger.info(url.request_uri)
              #req = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
              req = Net::HTTP::Post.new(url.request_uri, 'Content-Type' => 'application/json')
                  
              req.body = data
              res = http.request(req)
              logger.info("response")
              logger.info(JSON.parse(res.body)["errcode"])
              logger.info(JSON.parse(res.body)["errmsg"])
              logger.info(JSON.parse(res.body)["user_info"])
              logger.info(JSON.parse(res.body)["user_info"]["unionid"])
            
              # 获得用户id
              $dingid = JSON.parse(res.body)["user_info"]["dingId"]
              logger.info("dingid:#{$dingid}")
              rescue =>e
                logger.info("异常了-----------------------")
                logger.info(e)
                flash[:notice] = l(:flash_dingtalk_bind)
                return
              end
              
              logger.info("查询是否绑定dingId:#{$dingid}")
              user = User.find_by dingtalk_dingid: $dingid unless $dingid.blank?
              
              logger.info("是否存在该用户:#{!user.blank?}")
              unless user.blank?
                if user.active?
                  successful_authentication(user)
                else
                  handle_inactive_user(user)
                end
              else
                unless $dingid.blank?
                  flash[:notice] = l(:flash_dingtalk_bind)
                end
              end
              return
            end
          else  # 处理钉钉免登
            #填写确认并应用的应用key
            appkey = Setting["plugin_redmine_work_wechat"]["dingtalk_app_key"]
            #填写确认并应用的应用Secret
            appsecret = Setting["plugin_redmine_work_wechat"]["dingtalk_app_secret"]
            logger.info("appkey:#{appkey}")
            logger.info("appsecret:#{appsecret}")
            if (appkey.blank? || appsecret.blank?)
              flash[:error] = l(:flash_dingtalk_autologin_error)
              redirect_to home_url
              return
            end
            
            begin
              uri = URI.parse("https://oapi.dingtalk.com/gettoken?appkey=#{appkey}&appsecret=#{appsecret}")
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = true
              request = Net::HTTP::Get.new(uri.request_uri)  
              response = http.request(request)
          
              # 获得token
              token = JSON.parse(response.body)["access_token"]
              logger.info("token:#{token}")
              
              uri = URI.parse("https://oapi.dingtalk.com/user/getuserinfo?access_token=#{token}&code=#{auth_code}")
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = true
              request = Net::HTTP::Get.new(uri.request_uri)  
              response = http.request(request)
          
              # 获得errcode
              err_code = JSON.parse(response.body)["errcode"]
              logger.info("err_code:#{err_code}")          
              if err_code != 0
                flash[:error] = l(:flash_dingtalk_autologin_error)
                redirect_to home_url
                return
              end
              
              dingtalk_user_id = JSON.parse(response.body)["userid"]          
              logger.info("dingtalk_user_id:#{dingtalk_user_id}")
            rescue
              flash[:error] = l(:flash_dingtalk_autologin_error)
              redirect_to home_url
              return
            end
            user = User.find_by dingtalk_account_number: dingtalk_user_id unless dingtalk_user_id.blank?
            unless user.blank?
              if user.active?
                successful_authentication(user)
              else
                handle_inactive_user(user)
              end
            else
              flash[:error] = l(:flash_dingtalk_autologin_error)
              redirect_to home_url
            end
            return
          end
          login_without_login_dingtalk
        end
      end
      
      def successful_authentication_with_login_dingtalk(user)
        if !$dingid.blank?
          # 更新当前的dingid
          user.update_attributes(:dingtalk_dingid=>$dingid)
          $dingid = nil # 置空
        end
        successful_authentication_without_login_dingtalk user
      end
    end
  end
end

unless AccountController.included_modules.include?(RedmineQyWechat::Patches::AccountControllerPatch)
  AccountController.send(:include, RedmineQyWechat::Patches::AccountControllerPatch)
end