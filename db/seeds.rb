# メインのサンプルユーザーを1人作成する
User.create!(name: 'Example User',
             email: 'example@railstutorial.org',
             password: 'foobar',
             password_confirmation: 'foobar',
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

# 追加のユーザーをまとめて生成する
99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n + 1}@railstutorial.org"
  password = 'password'
  User.create!(name:,
               email:,
               password:,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content:) }
end

# ユーザーフォローのリレーションシップを作成する
users = User.all
user  = users.first
following = users[2..50]
followers = users[3..40]
following.each { |followed| user.follow(followed) }
followers.each { |follower| follower.follow(user) }

[[1, 2], [1, 2, 3], [4, 5]].each do |ids|
  raise unless channel = Channel.make_channel(ids)
  Message.create!(channel_id: channel.id, user_id: ids[0], content: "User#{ids[0]}のfirstメッセージ")
end

time = Time.current

[[1, 2], [2, 2], [2, 3]].each_with_index do |ids, i|
  channel = Channel.find_by(id: ids[0])
  if channel
    delayed_timestamp = time + (i + 1).minutes
    Message.create!(
      channel_id: ids[0],
      user_id: ids[1],
      content: "User#{ids[0]}のメッセージ",
      created_at: delayed_timestamp,
      updated_at: delayed_timestamp
    )
  else
    raise
  end
end
