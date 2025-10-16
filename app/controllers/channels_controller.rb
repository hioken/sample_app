class ChannelsController < ApplicationController
  before_action :logged_in_user, only: %i[index show]
  before_action :authenticate_dm_member, only: :show

  def index
    @channels = current_user.active_channels.order(last_message_at: :desc)
  end

  def show
    @messages = @channel.messages.includes(:user)
    cookies.encrypted[:sending_user_id] = current_user.id
  end

  def create
    # fix_point_2
    params[:user_ids] ||= []
    user_ids = params[:user_ids].unshift(current_user.id).uniq
    user_ids.each do |id|
      user = User.find_by(id: id)
      unless user
        @channels = current_user.active_channels.includes(:latest_message)
        @channel = Channel.new; @channel.errors.add(:channel_users, '無効なユーザーデータが送信されました')
        render :index
        return
      end
    end

    @channel = Channel.make_channel(user_ids)

    if @channel.errors.blank?
      redirect_to @channel
    else
      @channels = current_user.active_channels.includes(:latest_message)
      render :index
    end
  end

  def add_user
    #fix_point_2
    search_id = params[:unique_id].sub(/^@/, '')
    @user = User.find_by(unique_id: search_id) 

    respond_to do |format|
      if @user&.activated
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append(
              'members', partial: 'member', locals: {user: @user}
            ),
            turbo_stream.append(
              'members-params', partial: 'member_hidden_field', locals: {value: @user.id}
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
    channel_user = current_user.channel_users.find_by(channel_id: params[:id])
    channel_user.update(is_left: true)
    cookies.delete(:sending_user_id)
    flash[:success] = ''
    redirect_to channels_path
  end

  def suggest
    result = make_suggest(params[:unique_id_or_name])
  end

  private

  def authenticate_dm_member
    @channel = Channel.find(params[:id])
    unless @channel.is_member?(current_user.id)
      redirect_to channels_path
    end
  end

  def make_suggest(word)
    search_word = word.slice(0) == '@' ? "#{word}*" : "*#{to_codepoints_base32(word)}*"
    cursor, result = $redis_suggest_index.scan('0', match: search_word, count: 10)
    if cursor != '0'
      second = $redis_suggest_index.scan(cursor, match: search_word, count: 10)
      result.concat(second)
    end
    to_string_from_suggest_index(result)
  end

  def to_codepoints_base32(str)
    str.codepoints.map { |c| c.to_s(32) }.join(":")
  end

  def to_string_from_suggest_index(data) # コンソールで動作確認済み
    data.map do |record|
      record_tmp = record.split(':')
      uid = "@#{record_tmp.slice!(0)}"
      username = record_tmp.map!{ |c| c.to_i(32).chr }.join
      [uid, username]
    end
  end
end
