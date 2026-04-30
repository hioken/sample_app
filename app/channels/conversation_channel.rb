class ConversationChannel < ApplicationCable::Channel
  EVENT = {
    connected: 1,
    joined: 2,
    leaved: 3,
    message: 4,
    error: 400
  }

  def subscribed
    last_read_message_ids = $redis_readed.hgetall(last_read_message_ids_key(params[:conversation_id]))
    if last_read_message_ids.empty?
      last_read_message_ids = get_last_read_message_ids(params[:conversation_id])
      $redis_readed.mapped_hmset(last_read_message_ids_key(params[:conversation_id]), last_read_message_ids)
    else
      last_read_message_ids = last_read_message_ids.each { |k, v| last_read_message_ids[k] = v.to_i }
    end
    $redis_readed.hset(last_read_message_ids_key(params[:conversation_id]), connection.current_user.id, 0)
    last_read_message_ids.delete(connection.current_user.id.to_s)
    
    stream_from "conversation_#{params[:conversation_id]}"
    transmit({event: EVENT[:connected], params: {current_user_id: connection.current_user.id, last_read_message_ids: last_read_message_ids}})
    ActionCable.server.broadcast("conversation_#{params[:conversation_id]}", {event: EVENT[:joined], params: {user_id: connection.current_user.id}})
  end

  def unsubscribed
    last_message_id = $redis_readed.get(last_message_id_key(params[:conversation_id])) # fix_point5 これだともしredis_readedに保存出来ていなかった場合に、古い未読情報が残って見たのに未読マーク出る けど放置でもいいかも
    if last_message_id
      last_message_id = last_message_id.to_i
    else
      last_message_id = Message.where(conversation_id: params[:conversation_id]).select(:id).last.id
      $redis_readed.set(last_message_id_key(params[:conversation_id]), last_message_id)
    end
    ActionCable.server.broadcast("conversation_#{params[:conversation_id]}", {event: EVENT[:leaved], params: {user_id: connection.current_user.id, last_read_message_id: last_message_id}})

    ConversationUser.find_by(user_id: connection.current_user.id, conversation_id: params[:conversation_id]).update(last_read_message_id: last_message_id)
    $redis_readed.hset(last_read_message_ids_key(params[:conversation_id]), connection.current_user.id, last_message_id)
  end

  def activate(data)
  end

  def receive(data)
    message = Message.new(content: data["message"], user_id: connection.current_user.id, conversation_id: params[:conversation_id])
    if message.save
      ActionCable.server.broadcast("conversation_#{params[:conversation_id]}", {
        event: EVENT[:message],
        params: {
          message_element: ApplicationController.renderer.render(
            partial: 'messages/message',
            locals: { message: message, current_user: connection.current_user }
          )
        }
      })
      $redis_readed.set(last_message_id_key(params[:conversation_id]), message.id)
      notify(message)
    else
      transmit({event: EVENT[:error], params: message.errors.full_messages})
    end
  end

  private

  def notify(message)
      p "!!!!!!!!!"
      p "notify!!!!!!!!!!!"
    last_read_message_ids = $redis_readed.hgetall(last_read_message_ids_key(params[:conversation_id]))
    last_read_message_ids.each do |user_id, is_joined|
      if is_joined != "0"
        # ActionCable.server.broadcast("notification_#{user_id}", {
        #   message: truncate_message(message.content),
        #   user_name: message.user.name,
        #   conversation_id: params[:conversation_id]
        # })
        p "notification_#{user_id}"
        Turbo::StreamsChannel.broadcast_prepend_to(
          "notification_#{user_id}",
          target: "notification-container",
          partial: "messages/notification",
          locals: { 
            sender: message.user.name, 
            message: truncate_message(message.content), 
            time: message.created_at, 
            conversation_id: params[:conversation_id]
          }
        )
      end
    end
  end

  def get_last_read_message_ids(conversation_id)
    ConversationUser.where(conversation_id: conversation_id).pluck(:user_id, :last_read_message_id).to_h
  end

  def last_message_id_key(conversation_id)
    "conversation:#{conversation_id}:last_message_id"
  end

  def last_read_message_ids_key(conversation_id)
    "conversation:#{conversation_id}:last_read_message_ids"
  end

  def truncate_message(text, length = 40)
    text.length > length ? "#{text.slice(0, length)}..." : text
  end

end