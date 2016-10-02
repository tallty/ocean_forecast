require "numru/netcdf"

class Nafp::SurfaceWarm
  include Nafp

  def initialize
    @server = "10.228.2.53"
    @port = 21
    @user = "kfhyuser"
    @password = "0QY7rN86taOq"
    @file_pattern = "*surface-warms*"
    @local_dir = "./surface-warms"
  end

  def proc
    local_files = fetch
    local_files.each do |local_file|
      nc_filename = convert_grib_to_netcdf(local_file)
      puts "proc nc file #{nc_filename}..."
      extract_to_redis nc_filename, ["APCP_surface", "TMP_surface"]
    end
  end

  def extract_to_redis nc_filename, vars
    return if nc_filename.blank?
    _file = ::NumRu::NetCDF.open nc_filename
    _origin_time_string = to_datetime_string created_at(nc_filename)
    _time_string = to_datetime_string update_at(nc_filename)
    vars.each do |_var_name|
      _var = _file.var _var_name
      _lat_array = []
      _var.get.each.with_index do |_var_value, _index|
        _lon_index = _index % 759
        _lat_index = _index / 759
        _lat_array = [] if _lon_index == 0
        _lat_array << _var_value
        if _lon_index == 758
          _redis_key = "#{_var_name}_#{_time_string}"
          $redis.hset _redis_key, _lat_index, _lat_array.to_json
          $redis.expire _redis_key, 24*3600 #24 hours expire
        end
      end
    end
    $redis.hset("last_proc_time", self.class.to_s, _origin_time_string)
  end

  def extract_var_to_redis file, var_name
    
  end

  
end