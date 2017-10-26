redis_server = 'localhost'
redis_port = 6379
redis_db_num = 0
redis_namespace = 'ocean-sidekiq'
# settings = YAML.load(File.read(ENV["SETTINGS_PATH"]))

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{redis_server}:#{redis_port}/#{redis_db_num}", :size => 50, namespace: redis_namespace }
end

Sidekiq.configure_server do |config|
  config.redis =  { url: "redis://#{redis_server}:#{redis_port}/#{redis_db_num}", :size => 50, namespace: redis_namespace }
end
