class CorpWechatsController < ApplicationController
    unloadable
  #skip_before_filter :verify_authenticity_token
  #before_filter :find_project, :authorize, :only => [:new,:index]
  layout 'admin'
  before_action :require_admin
  def new
    @corp_wechat = CorpWechat.new
  end
  
  def create
    @corp_wechat = CorpWechat.new(corp_wechat_params)
    if @corp_wechat.save
      flash[:notice] = l(:notice_successful_create)  
      redirect_to :action =>"plugin", :id => "redmine_qy_wechats", :controller => "settings", :tab => 'corp_wechat'
    else
      render :action => 'new'
    end
  end
  
  def edit
    @corp_wechat = CorpWechat.find(params[:id])
  end
  
  def update
    @corp_wechat = CorpWechat.find(params[:id])
    if @corp_wechat.update_attributes(corp_wechat_params)
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action =>"plugin", :id => "redmine_qy_wechats", :controller => "settings", :tab => 'corp_wechat'
    else
      render :action => 'edit'
    end
  end
  
  
  def destroy
    @corp_wechat = CorpWechat.find(params[:id])
    @corp_wechat.destroy
    respond_to do |format|
      format.html { redirect_to :controller => 'settings', :action => 'plugin', :id => 'redmine_qy_wechats', :tab => 'corp_wechat'}
      format.api { render_api_ok }
    end
    @corp_wechats = CorpWechat.all - [@corp_wechat]
  end
  
  private
    def corp_wechat_params
      params.require(:corp_wechat).permit(:corp_id, :corp_secret,:app_id,:corp_name,:app_name,:author_id,:project_id)
    end
    def find_project
      @project = Project.find(params[:project_id])
    end
end
