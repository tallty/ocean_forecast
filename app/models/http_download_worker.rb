class HttpDownloadWorker
  require 'open-uri'
  include Sidekiq::Worker
  sidekiq_options retry: 5, queue: 'http_download'
  # before someone die ?
  sidekiq_retries_exhausted do |msg, e|
    Sidekiq.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
    $redis.srem "#{key}_downloading", name
  end

  def perform name, key, uri, target_dir
    p "Get #{[ name, key, uri, target_dir ]}"
    FileUtils.mkdir_p target_dir unless File.exist?(target_dir)
    target_path = File.join(target_dir, "#{name}.downloading")
    target_completed_path = File.join(target_dir, "#{name}")
    # w+ or wb+ or w+b
    # Truncate to zero length or create file for update.
    # WARNING: TODO: 两个同时读一个文件时 是否会冲突 ？？？
    File.open(target_path, "wb+") do |saved_file|
      # the following "open" is provided by open-uri
      open(uri, "rb") do |read_file|
        saved_file.write(read_file.read)
      end
    end
    # ensure
    #   f.close()
    FileUtils.mv target_path, target_completed_path
    $redis.srem "#{key}_downloading", name
  end
end
