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
      $redis.mapped_hmset(last_read_message_ids_key(params[:channel_id]), last_read_message_ids)
    else
      last_read_message_ids = last_read_message_ids.each { |k, v| last_read_message_ids[k] = v.to_i }
    end
    $redis.hset(last_read_message_ids_key(params[:channel_id]), connection.current_user.id, 0)
    last_read_message_ids.delete(connection.current_user.id.to_s)
    
    stream_from "channel_#{params[:channel_id]}"
    transmit({event: EVENT[:connected], params: {current_user_id: connection.current_user.id, last_read_message_ids: last_read_message_ids}})
    ActionCable.server.broadcast("channel_#{params[:channel_id]}", {event: EVENT[:joined], params: {user_id: connection.current_user.id}})
  end

  def unsubscribed
    last_message_id = $redis.get(last_message_id_key(params[:channel_id])) # fix_point5 これだともしredisに保存出来ていなかった場合に、古い未読情報が残って見たのに未読マーク出る けど放置でもいいかも
    if last_message_id
      last_message_id = last_message_id.to_i
    else
      last_message_id = Message.where(channel_id: params[:channel_id]).select(:id).last.id
      $redis.set(last_message_id_key(params[:channel_id]), last_message_id)
    end
    ActionCable.server.broadcast("channel_#{params[:channel_id]}", {event: EVENT[:leaved], params: {user_id: connection.current_user.id, last_read_message_id: last_message_id}})

    p '※※※※'
    p last_message_id
    p ChannelUser.find_by(user_id: connection.current_user.id, channel_id: params[:channel_id]).update(last_read_message_id: last_message_id)
    $redis.hset(last_read_message_ids_key(params[:channel_id]), connection.current_user.id, last_message_id)
  end

  def receive(data)
    message = Message.new(content: data["message"], user_id: connection.current_user.id, channel_id: params[:channel_id])
    if message.save
      ActionCable.server.broadcast(
        "channel_#{params[:channel_id]}",
        {
          event: EVENT[:message], params: {
          message_element: ApplicationController.renderer.render(
            partial: 'messages/message',
            locals: { message: message, current_user: connection.current_user }
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
