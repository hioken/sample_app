class BuildSuggestIndexJob < ApplicationJob
  queue_as :default

  def perform
    users = User.all
    unique_id_index = []
    name_index = []
    users.each do |user|
      userData = [user.id, user.unique_id, user.name]
      unique_id_index << userData
      name_index << [user.name.codepoints.join(':'), userData]
    end

    $redis_unique_id_index.set # jsonでhozon?
  end
end
