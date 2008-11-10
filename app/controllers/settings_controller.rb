class SettingsController < ApplicationController
  
  before_filter :login_required
  
  def show
    @delicious = DeliciousAccount.find_by_user_id(@current_user)
    
    @delicious = DeliciousAccount.new if @delicious.nil?
    
  end
  
  def update_delicious
    
    @delicious = DeliciousAccount.find_by_user_id(@current_user)
    
    if @delicious.nil?
      @delicious = DeliciousAccount.new(params[:delicious_account])
      @delicious.user = @current_user
      if @delicious.save
        flash[:error] = "error savin delicious account name"
      end
    else
      @delicious.update_attributes(params[:delicious_account])
    end
  end
end
