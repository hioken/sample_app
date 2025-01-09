class MessageShowChannel < ApplicationCable::Channel
  def subscribed
    stream_from "channel_#{params[:channel_id]}"
  end
  
  def receive(data)
    message = Message.new(content: data["message"], user_id: connection.current_user_id, channel_id: params[:channel_id])
    if message.save
      ActionCable.server.broadcast(
        "channel_#{params[:channel_id]}",
        { message_element: ApplicationController.renderer.render(
            partial: 'messages/message',
            locals: { message: message }
          )
        }
      )
    else
      transmit({status: :internal_server_error, error: message.errors.full_messages})
    end
  end
end
