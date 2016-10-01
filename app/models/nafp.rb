module Nafp
  include FtpConcern

  def convert_grib_to_netcdf
    system "#{ENV["wgrib2_path"]/wgrib2} #{grib_filename} -netcdf #{nc_filename}"
  end
  
  def fetch
    self.connect
    today = Time.zone.today
    today_dir = today.strftime('%Y/%m/%d')
    yestoday = today - 1.day
    yestoday_dir = yestoday.strftime('%Y/%m/%d')

    remote_files = []
    ["#{yestoday_dir}/00", "#{yestoday_dir}/12", "#{today_dir}/00", "#{today_dir}/12"].each do |dir|
      last_proc_time = Time.zone.parse MultiJson.load($redis.hget("last_proc_time", self.class.to_s)) rescue Time.zone.now-1.day
      @connection.chdir dir rescue next
      files = self.ls @file_pattern
      files.each do |file|
        remote_files << File.join(dir, file) if created_at(file) > last_proc_time
      end

    end
    
    puts "files is:#{files.inspect}"
    files
  end

  def created_at filename
    time_string = filename.split("_")[-3]
    Time.zone.parse(time_string)+8.hour
  end

  def to_datetime_string time
    time.strftime('%Y%m%d%H')
  end
end