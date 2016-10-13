class Noaa::Wave
  include Noaa

  def initialize
    @server = "ftpprd.ncep.noaa.gov"
    @port = 21
    @passive = true
    @file_pattern = "nww3.*.grib.grib2"
    @local_dir = "./ftp/wave"
    @remote_dir = "/pub/data/nccf/com/wave/prod"
  end

  def fetch
    return if processing?

    begin
      $redis.set "#{self.class.to_s}#processing", true
      connect = self.connect

      today = Time.zone.today
      today_dir = today.strftime('multi_1.%Y%m%d')

      dir = File.join @remote_dir, today_dir
      @connection.chdir dir rescue return

      files = self.ls @file_pattern
      files.each do |file|
        last_proc_time = ( Time.zone.parse $redis.hget("last_proc_time", self.class.to_s) rescue Time.zone.now-1.day )
        local_dir = File.join @local_dir, today_dir
        local_file = File.join local_dir, file

        file_created_at = created_at(local_file)
        next unless file_created_at > last_proc_time

        FileUtils.mkdir_p local_dir
        
        puts "begin to download #{file}, save to #{local_file}"
        @connection.getbinaryfile(file, local_file) rescue retry

        $redis.hset("last_proc_time", self.class.to_s, to_datetime_string(file_created_at) )
      end
    ensure
      $redis.del "#{self.class.to_s}#processing"
    end
  end



  def created_at local_file
    filedir = File.dirname local_file
    filename = File.basename local_file
    delta_hour = filename.split(/\.t|z\./)[1].to_i
    time_string = filedir.split("multi_1.")[-1]
    Time.zone.parse(time_string)+delta_hour.hours
  end

end