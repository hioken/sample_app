$redis_readed = Redis.new(url: ENV["REDIS_URL"] + '/1')
$redis_suggest_index = Redis.new(url: ENV["REDIS_URL"] + '/2')