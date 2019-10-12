module RedmineQyWechat
  module Patches
    module ProjectPatch
      def self.included(base) # :nodoc: 
        base.class_eval do    
          unloadable # Send unloadable so it will not be unloaded in development
          #has_many :qy_wechat_users, :dependent => :destroy
          has_many :corp_wechats, :dependent => :destroy
        end  
      end  
    end
  end
end
unless Project.included_modules.include?(RedmineQyWechat::Patches::ProjectPatch)
  Project.send(:include, RedmineQyWechat::Patches::ProjectPatch)
end