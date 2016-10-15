class Noaa::Gfs
  include Noaa

  def initialize
    @server = "ftpprd.ncep.noaa.gov"
    @port = 21
    @passive = true
    @local_dir = "../ftp/gfs"
    @remote_dir = "/pub/data/nccf/com/gfs/prod"

    @file_pattern = "gfs.t*pgrb2full*"
  end

  def self.force_fetch date
    Noaa::Gfs.new.fetch_by_date date
  end

  def fetch
    return if processing?

    today = Time.zone.today
    fetch_by_date today
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

  def fetch_by_date date
    $redis.set "#{self.class.to_s}#processing", true
    connect = self.connect

    date_dir = "gfs." + date.strftime('%Y%m%d')
    ["#{date_dir}00", "#{date_dir}06", "#{date_dir}12", "#{date_dir}18"].each do |_dir|
      dir = File.join @remote_dir, _dir
      last_proc_time = ( Time.zone.parse $redis.hget("last_proc_time", self.class.to_s) rescue Time.zone.now-10.day )
      file_created_at = Time.zone.parse(_dir)
      next unless file_created_at > last_proc_time

      @connection.chdir dir rescue next
      files = self.ls @file_pattern rescue retry

      files.each do |file|
        next unless valid_file? file

        local_dir = File.join @local_dir, _dir
        local_file = File.join local_dir, "#{file}.grib2"

        FileUtils.mkdir_p local_dir

        begin
          if self.closed?
            puts "#{Time.zone.now} reconnect ftp connection"
            self.connect
            @connection.chdir dir
          end
          puts "#{Time.zone.now} remote dir is: #{@connection.getdir}"
          puts "#{Time.zone.now} begin to download #{file}, save to #{local_file}"
          @connection.getbinaryfile(file, local_file) 
        rescue Exception => e
          self.close
          puts e.backtrace
          sleep 2
          retry
        end

      end
      $redis.hset("last_proc_time", self.class.to_s, to_datetime_string(file_created_at) )
    end
  ensure
    self.close
    $redis.del "#{self.class.to_s}#processing"
  end


end