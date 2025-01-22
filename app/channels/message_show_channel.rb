class MessageShowChannel < ApplicationCable::Channel
  EVENT = {
    connected: 1,
    joined: 2,
    leaved: 3,
    message: 4,
    error: 400
  }

  def subscribed
    last_read_message_ids = $redis.hgetall(last_read_message_ids_key(params[:channel_id]))
    if last_read_message_ids.empty?
      last_read_message_ids = get_last_read_message_ids(params[:channel_id])
      $redis.hset(last_read_message_ids_key(params[:channel_id]), last_read_message_ids)
    end
    stream_from "channel_#{params[:channel_id]}"
    transmit({event: EVENT[:connected], params: {current_user_id: connection.current_user_id, last_read_message_ids: last_read_message_ids}})
    ActionCable.server.broadcast("channel_#{params[:channel_id]}", {event: EVENT[:joined], params: {user_id: connection.current_user_id}})
  end

  def unsubscribed
    ActionCable.server.broadcast({event: EVENT[:leaved], params: {user_id: connection.current_user_id}})
    last_message_id = $redis.get(last_message_id_key(params[:id]))
    if ChannelUser.find_by(user_id: connection.current_user_id, channel_id: params[:channel_id]).update(last_message_id)
      $redis.hset(last_read_message_ids(params[:id]), connection.current_user_id, last_message_id)
    end
  end

  def receive(data)
    message = Message.new(content: data["message"], user_id: connection.current_user_id, channel_id: params[:channel_id])
    if message.save
      ActionCable.server.broadcast(
        "channel_#{params[:channel_id]}",
        {
          event: EVENT[:message], params: {
          message_element: ApplicationController.renderer.render(
            partial: 'messages/message',
            locals: { message: message }
          )}
        }
      )
      $redis.set(last_message_id_key(params[:channel_id]), message.id)
    else
      transmit({event: EVENT[:error], params: message.errors.full_messages})
    end
  end

  private

  def get_last_read_message_ids(channel_id)
    ChannelUser.where(channel_id: channel_id).pluck(:user_id, :last_read_message_id).to_h
  end

  def last_message_id_key(channel_id)
    "channel:#{channel_id}:last_message_id"
  end

  def last_read_message_ids_key(channel_id)
    "channel:#{channel_id}:last_read_message_ids"
  end
end
