module Shnwp
  include FtpConcern

  def fetch_latest
    unless processing?
      fetch_by_date Time.zone.today - 1.day
      fetch_by_date Time.zone.today  
    end
  end

  def self.get_data_json data_type, date_string
    date = Date.parse date_string rescue Time.zone.today
    data_class = case data_type.downcase
    when "gfs"
      "Shnwp::Gfs"
    when "hycom"
      "Shnwp::Hycom"
    when "nww3"
      "Shnwp::Nww3"
    when "nww3sh"
      "Shnwp::Nww3Sh"
    when "cw"
      "Shnwp::Cw"
    when "fc"
      "Shnwp::Fc"
    when "warms"
      "Shnwp::Warms"
    else
      return {error: "data type is error: #{data_type}"}
    end
    redis_key = "#{data_class}#data##{date.strftime('%Y%m%d')}"
    periods = $redis.hkeys(redis_key)
    periods_hash = periods.map do |period|
      files = MultiJson.load($redis.hget(redis_key, period))
      {
        period: period,
        files: files
      }
    end
    {
      type: data_type,
      date: date,
      periods: periods_hash
    }
  end

  def processing?
      $redis.get("#{self.class.to_s}#processing").present? 
  end

  def to_datetime_string time
    time.strftime('%Y%m%d%H')
  end

  def fetch_by_date date
    $redis.set "#{self.class.to_s}#processing", true
    self.connect

    date_string = date.strftime('%Y/%m/%d')
    puts "date_string is:#{date_string}"

    fetch_folder date_string
  ensure
    $redis.del "#{self.class.to_s}#processing"
    self.close
  end

  private
    def fetch_folder folder
      url = "http://61.152.122.112:8080/ocean"

      dir = File.join @remote_dir, folder
      @connection.chdir dir rescue return
      @connection.nlst @file_pattern # FC数据第一次取不到数据，这里强行获取一次目录中的文件
      files = self.ls @file_pattern rescue retry
      file_info_arr = []

      return nil if files.blank?

      files.each do |file|
        local_dir = File.join @local_dir, folder
        local_file = File.join local_dir, "#{file}"
        FileUtils.mkdir_p local_dir

        too_large_error = false
        begin
          if self.closed?
            puts "#{Time.zone.now} reconnect ftp connection"
            self.connect
            @connection.chdir dir
          end
          puts "#{Time.zone.now} remote dir is: #{@connection.getdir}"
          puts "#{Time.zone.now} begin to download #{file}, save to #{local_file}"
          if File.exists?(local_file) && too_large_error
            FileUtils.rm local_file 
            too_large_error = false
          end
          @connection.getbinaryfile(file, local_file)

          file_path = local_file.sub("./public/", "")
          file_info_arr << { filename: file, url: "#{url}/#{file_path}" }

          # Save file informations to redis when processing data on time
          ufolder = folder.gsub "/", ""
          redis_key = "#{self.class.to_s}#data##{ufolder[0..7]}"
          $redis.hset(redis_key, ufolder, file_info_arr.to_json)
          $redis.expire redis_key, 7*24*3600 # 7days expire
        rescue Exception => e
          self.close
          p e
          puts e.backtrace
          too_large_error = true if e.message.include?('too large')
          sleep 10
          retry
        end
      end

      # Save file informations to redis
      folder = folder.gsub "/", ""
      redis_key = "#{self.class.to_s}#data##{folder[0..7]}"
      $redis.hset(redis_key, folder, file_info_arr.to_json)
      $redis.expire redis_key, 7*24*3600 # 7days expire

      files
    end
end
