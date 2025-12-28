class UsersController < ApplicationController
  before_action :logged_in_user, only: %i[index edit update destroy following followers]
  before_action :correct_user,   only: %i[edit update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(activated: true, is_deleted: false).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_url
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def unsubscribe
    if current_user.unsubscribe
      flash[:success] = 'unsubscribed'
      reset_session
      redirect_to about_path
    else
      flash[:danger] = 'failed'
      redirect_to home_path
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_url, status: :see_other
  end

  def destroy_not_activated
    User.where(activated: false).destroy_all
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def suggest
    search_word = params[:uid_or_name].slice(0) == '@' ? "#{params[:uid_or_name][1..]}*" : "*#{to_codepoints_base32(params[:uid_or_name])}*"
    cursor, result = $redis_suggest_index.scan('0', match: search_word, count: 10)
    # if cursor != '0'
    #   second = $redis_suggest_index.scan(cursor, match: search_word, count: 10)
    #   result.concat(second)
    # end
    result = to_string_from_suggest_index(result)
    p "!!!!!!!!"
    p result
    render turbo_stream: turbo_stream.update(
      "suggest-list",
      partial: "users/suggest",
      locals: { suggest: result }
    )
    # render json: result   
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :unique_id,
                                 :password_confirmation)
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin?
  end

  def to_codepoints_base32(str)
    str.codepoints.map { |c| c.to_s(32) }.join(":")
  end

  def to_string_from_suggest_index(data)
    data.map do |record|
      record_tmp = record.split(':')
      uid = "@#{record_tmp.slice!(0)}"
      username = record_tmp.map!{ |c| c.to_i(32).chr }.join
      [uid, username]
    end
  end
end
