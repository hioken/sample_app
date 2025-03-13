$redis_readed = Redis.new(url: ENV["REDIS_URL"] + '/1')
$redis_unique_id_index = Redis.new(url: ENV["REDIS_URL"] + '/2')
$redis_name_index = Redis.new(url: ENV["REDIS_URL"] + '/3')