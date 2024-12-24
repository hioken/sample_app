class ChannelsController < ApplicationController
  def index
    @channels = current_user.channels.includes(:latest_message)
  end

  def show
    @channel = Channel.find(params[:id])
    @messages = @channel.messages.includes(:user)
  end
end
