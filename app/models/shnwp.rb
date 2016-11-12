module Shnwp
  include FtpConcern

  def processing?
      $redis.get("#{self.class.to_s}#processing").present? 
  end

  def to_datetime_string time
    time.strftime('%Y%m%d%H')
  end

  def fetch_by_date date
    $redis.set "#{self.class.to_s}#processing", true
    connection = self.connect

    date_string = date.strftime('%Y%m%d')
    puts "date_string is:#{date_string}"
    @connection.chdir @remote_dir
    dirs = self.ls rescue retry
    dirs.select! { |dir| dir.start_with? date_string }
    
    dirs.each do |folder|
      last_proc_time = ( Time.zone.parse $redis.hget("last_proc_time", self.class.to_s) rescue Time.zone.now-10.day )
      file_created_at = Time.zone.parse(folder)
      next unless file_created_at > last_proc_time

      fetch_folder folder

      $redis.hset("last_proc_time", self.class.to_s, folder )
    end
  ensure
    self.close
    $redis.del "#{self.class.to_s}#processing"
  end

  private
    def fetch_folder folder
      dir = File.join @remote_dir, folder
      @connection.chdir dir rescue retry
      files = self.ls @file_pattern rescue retry

      files.each do |file|
        local_dir = File.join @local_dir, folder
        local_file = File.join local_dir, "#{file}"
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
          sleep 10
          retry
        end
      end
    end
end