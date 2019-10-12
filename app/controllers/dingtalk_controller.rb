class DingtalkController < ApplicationController
  def start_dingtalk_flow
    # flow_flag = Setting["plugin_redmine_work_wechat"]["dingtalk_approval_flow_enabled"]
    flow_flag = "0" 
    #填写确认并应用的企业ID
    corpid = Setting["plugin_redmine_work_wechat"]["dingtalk_corp_id"]
    #填写确认并应用的应用Secret
    # corpsecret = Setting["plugin_redmine_work_wechat"]["dingtalk_corp_secret"]
    #填写确认并应用的应用key
    appkey = Setting["plugin_redmine_work_wechat"]["dingtalk_app_key"]
    #填写确认并应用的应用Secret
    appsecret = Setting["plugin_redmine_work_wechat"]["dingtalk_app_secret"]
    #填写正确的redmine审批部门
    approval_dept_id = Setting["plugin_redmine_work_wechat"]["dingtalk_approval_dept_id"]
      
    appid = Setting["plugin_redmine_work_wechat"]["dingtalk_app_id"]
    #对应的审批流编号
    approval_flow_no = Setting["plugin_redmine_work_wechat"]["dingtalk_approval_flow_no"]
    if flow_flag == "0" || corpid.blank? || appkey.blank? || appsecret.blank? || appid.blank? || approval_dept_id.blank? || approval_flow_no.blank?
      flash[:notice] = l(:flash_dingtalk_setting_lack)
      @err_response = l(:lable_err_setting_null)
      return
    end
    
    # 获取issue参数
    @issue_id = params[:id]
    # uri = URI.parse("https://oapi.dingtalk.com/gettoken?corpid=#{corpid}&corpsecret=#{corpsecret}")
    uri = URI.parse("https://oapi.dingtalk.com/gettoken?appkey=#{appkey}&appsecret=#{appsecret}")
    # 改成异常捕捉，避免is_valid?方法本身的出错
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(uri.request_uri)  
      response = http.request(request)
          
      # 获得token
      token = JSON.parse(response.body)["access_token"]
    
      logger.info(JSON.parse(response.body)["errcode"])
      logger.info(JSON.parse(response.body)["errmsg"])
      logger.info(JSON.parse(response.body)["access_token"])
      
      url =  URI.parse("https://eco.taobao.com/router/rest")

      issue = Issue.find(@issue_id)
      # 获得任务信息
      issue_name = issue.subject
      issue_desc = issue.description
      project_name = issue.project.name
      
      # 获得作者信息，并作为审批发起者
      author = issue.author
      author_dt_id = author.dingtalk_account_number if !author.blank?
      if author_dt_id.blank?
        flash[:error] = l(:flash_dingtalk_flow_wrong)
        @err_response = l(:lable_err_author_null)
        return
      end
      
      
      # 获得指派者信息，作为审批者
      assign = issue.assigned_to
      assign_dt_id = assign.dingtalk_account_number if !assign.blank?
      if assign.blank? || assign_dt_id.blank?
        flash[:error] = l(:flash_dingtalk_flow_wrong)
        @err_response = l(:lable_err_assign_null)
        return
      end
      # 获得跟踪者信息，作为抄送者
      watchers = issue.watchers
      watchers_dt_ids = ""
      watchers.each do |w|
        unless w.blank? && w.user.blank? && w.user.dingtalk_account_number.blank?
          watchers_dt_ids.concat(w.user.dingtalk_account_number).concat(",")
        end
      end
      
      params = {
        "format"=>"json",
        "method"=>"dingtalk.smartwork.bpms.processinstance.create",
        "partner_id"=>"apidoc",
        "session"=>token,
        "timestamp"=>"2017-09-14+16%3A34%3A52",
        "v"=>"2.0",
        "agent_id"=>appid,
        "approvers"=>assign_dt_id,
        "cc_position"=>"START",
        "dept_id"=>approval_dept_id,
        "form_component_values"=>"[{'name':'#{l(:flow_project_name)}','value':'#{project_name}'}, {'name':'#{l(:flow_issue_id)}','value':'#{@issue_id}'}, {'name':'#{l(:flow_issue_name)}','value':'#{issue_name}'}, {'name':'#{l(:flow_issue_desc)}','value':'#{issue_desc}'}]",
        "originator_user_id"=>author_dt_id,
        "process_code"=>approval_flow_no,
        "cc_list"=>watchers_dt_ids
      }
      
      
      # "PROC-52IKRYIV-CVBONT54SMZ0MYIVMQLL1-XTRG4K7J-4"
      
      res = Typhoeus::Request.post("https://eco.taobao.com/router/rest", :params => params, :headers=>{"Content-type"=>"application/x-www-form-urlencoded", "charset"=>"utf-8"})
        
      # http = Net::HTTP.new(url.host,url.port)
      # http.use_ssl = true
      # #req = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
      # # req = Net::HTTP::Post.new(url.request_uri, 'Content-Type' => 'application/json')
      # req = Net::HTTP::Post.new(url.request_uri, 'Content-Type' => 'application/x-www-form-urlencoded;charset=utf-8')
          

      
      # req.body = data
      # res = http.request(req)
      res_body = JSON.parse(res.body)
      error_response = res_body["error_response"]
      
      if error_response.blank?
        flash[:notice] = l(:flash_dingtalk_flow_start)
      else
        flash[:error] = l(:flash_dingtalk_flow_wrong)
        @err_response = error_response
      end
    rescue
      flash[:error] = l(:flash_dingtalk_flow_wrong)
      @err_response = l(:lable_err_unknown)
    end
    
    
  end
  
  # private
end
