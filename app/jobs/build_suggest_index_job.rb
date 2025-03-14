class BuildSuggestIndexJob < ApplicationJob
  queue_as :default

  def perform
    users = User.all
    redis_index = users.map { |user| ["#{user.unique_id}:#{to_codepoints_hex(user.name)}", "" ] }
    $redis_suggest_index.mset(*redis_index)
  end

  private
  
  def to_codepoints_hex(str)
    str.codepoints.map { |c| c.to_s(16) }.join(":")
  end
end
