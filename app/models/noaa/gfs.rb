class Noaa::Gfs
  include Noaa

  def initialize
    @server = "ftpprd.ncep.noaa.gov"
    @port = 21
    @passive = true
    @local_dir = "../ftp/wave"
    @remote_dir = "/pub/data/nccf/com/gfs/prod"

    @file_pattern = "gfs.t*pgrb2full*"
    # @file_pattern << "("
    # (0..80).each do |index|
    #   str = (index * 3).to_s.rjust(3, '0')
    #   @file_pattern << "#{str}|"
    # end
    # @file_pattern << ")"
  end

  def fetch
    return if processing?

    begin
      $redis.set "#{self.class.to_s}#processing", true
      connect = self.connect

      today = Time.zone.today
      today_dir = "gfs." + today.strftime('%Y%m%d')
      ["#{today_dir}00", "#{today_dir}06", "#{today_dir}12", "#{today_dir}18"].each do |_dir|
        dir = File.join @remote_dir, _dir
        last_proc_time = ( Time.zone.parse $redis.hget("last_proc_time", self.class.to_s) rescue Time.zone.now-1.day )
        file_created_at = Time.zone.parse(_dir)
        next unless file_created_at > last_proc_time

        @connection.chdir dir rescue next
        files = self.ls @file_pattern

        files.each do |file|
          next unless valid_file? file
          
          local_dir = File.join @local_dir, today_dir
          local_file = File.join local_dir, file

          FileUtils.mkdir_p local_dir
          
          puts "begin to download #{file}, save to #{local_file}"
          @connection.getbinaryfile(file, local_file) rescue retry
        end
        $redis.hset("last_proc_time", self.class.to_s, to_datetime_string(file_created_at) )
      end
    ensure
      $redis.del "#{self.class.to_s}#processing"
    end
  end

  def created_at local_file
    filedir = File.dirname local_file
    time_string = filedir.split("gfs.")[-1]
    Time.zone.parse(time_string)
  end

  def valid_file? file
    extname = File.extname(file)
    if extname == ".idx"
      return false
    else
      hour_index = extname.sub(".f", "").to_i
      if hour_index > 240
        return false
      end
    end
    return true
  end


end