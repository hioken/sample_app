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

  private

  def authenticate_dm_member
    @channel = Channel.find(params[:id])
    unless @channel.is_member?(current_user.id)
      redirect_to channels_path
    end
  end
end
