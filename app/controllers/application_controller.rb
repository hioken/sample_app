class ApplicationController < ActionController::Base
  include SessionsHelper

  private

  # ユーザーのログインを確認する
  def logged_in_user
    if logged_in?
      if current_user.is_deleted
        flash[:danger] = 'this user is deleted'
        redirect_to about_url, status: :see_other
      end
    else
      store_location
      flash[:danger] = 'Please log in.'
      redirect_to login_url, status: :see_other
    end
  end
end
