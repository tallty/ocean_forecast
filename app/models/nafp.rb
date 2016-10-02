module Nafp
  include FtpConcern

  def convert_grib_to_netcdf
    system "#{ENV['wgrib2_path']}/wgrib2 #{grib_filename} -netcdf #{nc_filename}"
  end
  
  def fetch
    self.connect
    today = Time.zone.today
    today_dir = today.strftime('%Y/%m/%d')
    yestoday = today - 1.day
    yestoday_dir = yestoday.strftime('%Y/%m/%d')

    local_files = []
    # 由于有延迟的原因，所以需要把昨天和今天的可能目录都遍历一遍
    ["#{yestoday_dir}/00", "#{yestoday_dir}/12", "#{today_dir}/00", "#{today_dir}/12"].each do |dir|
      last_proc_time = ( Time.zone.parse MultiJson.load($redis.hget("last_proc_time", self.class.to_s)) rescue Time.zone.now-1.day )
      @connection.chdir dir rescue next
      files = self.ls @file_pattern
      puts "in #{dir}, files is:#{files}"
      files.each do |file|
        # 只处理未处理过的文件
        if created_at(file) > last_proc_time
          # 将远程文件拷贝到本地
          local_day_dir = File.join @local_dir, dir
          FileUtils.mkdir_p local_day_dir
          local_file = File.join local_day_dir, "#{file}.grb"
          @connection.getbinaryfile(file, local_file)
          local_files << local_file
        end
      end
    end
    
    puts "local_files is:#{local_files.inspect}"
    local_files
  end

  def created_at filename
    time_string = filename.split("_")[-3]
    Time.zone.parse(time_string)+8.hour
  end

  def to_datetime_string time
    time.strftime('%Y%m%d%H')
  end
end