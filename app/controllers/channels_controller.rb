class ChannelsController < ApplicationController
  before_action :authenticate_dm_member, only: :show

  def index
    @channels = current_user.channels.includes(:latest_message)
  end

  def show
    @messages = @channel.messages.includes(:user)
  end

  def create
    channel = Channel.make_channel(params[:user_ids].map(&:to_i))
    if channel.valid?
      redirect_to channel
    else
      @channels = current_user.channels.includes(:latest_message)
      render :index
    end
  end

  def add_user
    @user = User.find_by(email: params[:email])
    @user = User.first
    respond_to do |format|
      if @user && @user.activated
        format.js
      else
        format.js {render :undefind }
      end
    end
  end

def add_user
  @user = User.find_by(email: params[:email])
  @user ||= User.first

  respond_to do |format|
    if @user&.activated
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          'user-list',
          partial: 'user',
          locals: { user: @user }
        )
      end
    else
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          'add-user-form',
          partial: 'form',
          locals: { error: 'User not found or not activated.' }
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
