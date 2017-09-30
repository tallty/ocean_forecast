class Shnwp::Warms
  include Shnwp

  def initialize
    @server = "10.228.2.53"
    @port = 21
    @passive = true
    @user = "kefuuser"
    @password = "TpTCEWRz"
    @local_dir = "../sh_weather/public/warms"
    @remote_dir = "/"

    @file_pattern = "*surface-warms*"
  end

  def fetch_by_date date
    $redis.set "#{self.class.to_s}#processing", true
    connection = self.connect

    date_string = date.strftime('%Y/%m/%d')
    puts "date_string is:#{date_string}"
    @connection.chdir date_string
    dirs = self.ls rescue [00, 12]
    dirs.select! { |dir| ['00', '12'].include? dir }
    
    dirs.each do |folder|
      last_proc_time = ( Time.zone.parse $redis.hget("last_proc_time", self.class.to_s) rescue Time.zone.now-10.day )

      folder = "#{date_string} folder"
      file_created_at = Time.zone.parse(folder)
      next unless file_created_at > last_proc_time

      files = fetch_folder folder

      $redis.hset("last_proc_time", self.class.to_s, folder ) if files.present?
    end
  ensure
    $redis.del "#{self.class.to_s}#processing"
    self.close
  end
end
