class ConversationsController < ApplicationController
  before_action :logged_in_user, only: %i[index show]
  before_action :authenticate_dm_member, only: :show

  def index
    @conversations = current_user.active_conversations_with_status
  end

  def show
    @messages = @conversation.messages.includes(:user)
    cookies.encrypted[:sending_user_id] = current_user.id
  end

  def create
    params[:user_ids] ||= []
    user_ids = params[:user_ids].unshift(current_user.id).uniq
    @conversations = current_user.active_conversations_with_status
    user_ids.each do |id|
      user = User.find_by(id: id)
      unless user
        @conversation = Conversation.new; @conversation.errors.add(:conversation_users, '無効なユーザーデータが送信されました')
        render :index
        return
      end
    end

    @conversation = Conversation.make_conversation(user_ids)

    if @conversation.errors.blank?
      redirect_to @conversation
    else
      render :index
    end
  end

  def add_user
    search_id = params[:unique_id].sub(/^@/, '')
    @user = User.find_by(unique_id: search_id) 

    respond_to do |format|
      if @user&.activated
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              'members', partial: 'add_member_item', locals: {user: @user}
            ),
            turbo_stream.replace(
              'add-member-form', partial: 'add_member_form', locals: { undefind_user: nil }
            )
          ]
        end
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'add-member-form', partial: 'add_member_form', locals: { undefind_user: params[:unique_id] }
          )
        end
      end
    end
  end

  def leave
    conversation_user = current_user.conversation_users.find_by(conversation_id: params[:id])
    conversation_user.update(is_left: true)
    cookies.delete(:sending_user_id)
    flash[:success] = ''
    redirect_to conversations_path
  end

  private

  def authenticate_dm_member
    @conversation = Conversation.find(params[:id])
    unless @conversation.is_member?(current_user.id)
      redirect_to conversations_path
    end
  end
end
