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
    nc_files = fetch
    extract_to_redis nc_files.first
  end

  def extract_to_redis nc_filename
    return if nc_filename.blank?
    _file = ::NumRu::NetCDF.open nc_filename
    _time_string = to_datetime_string created_at(nc_filename)
    _var_name = "APCP_surface"
    _var = _file.var _var_name
    _lat_array = []
    _var.get.each.with_index do |_var_value, _index|
      _lon_index = _index % 759
      _lat_index = _index / 759
      _lat_array = [] if _lon_index == 0
      _lat_array << _var_value
      if _lon_index == 758
        _redis_key = "#{_var_name}_#{_time_string}"
        $redis.hset _redis_key, _lat_index, _lat_array  
      end
    end
  end

  
end