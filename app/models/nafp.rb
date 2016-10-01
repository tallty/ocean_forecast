module Nafp
  include FtpConcern

  def convert_grib_to_netcdf
    system "#{ENV["wgrib2_path"]/wgrib2} #{grib_filename} -netcdf #{nc_filename}"
  end
  
  def fetch
    self.connect
    today = Time.zone.today
    today_dir = today.strftime('%Y/%m/%d/')
    @connection.chdir today_dir
    files = self.ls
    puts "files is:#{files.inspect}"
  end
end