class MessageChannel < ApplicationCable::Channel
  def subscribed
  end

  def unsubscribed
  end

  # def recieve
  #   # Channel.make_channel if params[:frist]
  # end
end
