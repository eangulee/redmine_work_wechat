module RedmineQyWechat
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development
          
          safe_attributes 'corp_wechat_account_number'
          safe_attributes 'dingtalk_account_number'
          safe_attributes 'dingtalk_dingid'
          
        end
      end
    end
  end
end
unless User.included_modules.include?(RedmineQyWechat::Patches::UserPatch)
  User.send(:include, RedmineQyWechat::Patches::UserPatch)
end