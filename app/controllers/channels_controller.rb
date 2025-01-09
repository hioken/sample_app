class ChannelsController < ApplicationController
  # fix_point_1 id実装後emailの部分変更
  before_action :authenticate_dm_member, only: :show

  def index
    @channels = current_user.channels.includes(:latest_message).order(last_message_at: :desc)
  end

  def show
    @messages = @channel.messages.includes(:user)
    cookies.encrypted[:sending_user_id] = current_user.id
  end

  def create
    params[:emails] ||= []
    params[:emails] << current_user.email
    params[:emails] = params[:emails].uniq
    user_ids = params[:emails].map do |e|
      user = User.find_by(email: e)
      unless user
        @channels = current_user.channels.includes(:latest_message)
        @channel = Channel.new; @channel.errors.add(:channel_users, '無効なユーザーデータが送信されました')
        render :index
        return
      end
      user.id
    end

    @channel = Channel.make_channel(user_ids)

    if @channel.errors.blank?
      redirect_to @channel
    else
      @channels = current_user.channels.includes(:latest_message)
      render :index
    end
  end

  def add_user
    @user = User.find_by(email: params[:email])

    respond_to do |format|
      if @user&.activated
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              'members', partial: 'member', locals: {user: @user}
            ),
            turbo_stream.append(
              'members-params', partial: 'member_hidden_field', locals: {value: @user.email}
            ),
            turbo_stream.replace(
              'add-member-form', partial: 'add_member_form', locals: { undefind_user: nil }
            )
          ]
        end
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'add-member-form', partial: 'add_member_form', locals: { undefind_user: params[:email] }
          )
        end
      end
    end
  end

  private

  def authenticate_dm_member
    @channel = Channel.find(params[:id])
    unless @channel.is_member?(current_user.id)
      redirect_to channels_path
    end
  end
end
