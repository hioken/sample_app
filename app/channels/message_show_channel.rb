class MessageShowChannel < ApplicationCable::Channel
  def subscribed
    stream_from "channel_#{params[:channel_id]}"
  end
  
  def receive(data)
    message = Message.new(content: data[:message], user: current_user)
    if message.save
      ActionCable.server.broadcast(
        "channel_#{params[:channel_id]}",
        { message_element: ApplicationController.renderer.render(
            partial: 'channels/message',
            locals: { message: message }
          )
        }
      )
    else
      ActionCable.server.broadcast(
        "channel_#{params[:channel_id]}", 
        {error: message.errors.full_messages}
      )
    end
  end
end
