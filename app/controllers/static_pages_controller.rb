class StaticPagesController < ApplicationController
  def home
    @micropost = current_user.microposts.build if logged_in?
  end

  def about; end

  def help; end

  def contact; end
end
