$redis_readed = Redis.new(url: ENV["REDIS_URL"] + '/1')
$redis_suggest = Redis.new(url: ENV["REDIS_URL"] + '/2')