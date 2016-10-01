class NAFP::HighWarm
  include NAFP

  attr_reader :grib_filename, :nc_filename

  def initialize(grib_filename)
    @grib_filename = @grib_filename
    @nc_filename = "#{grib_filename}.nc" 
    @server = "10.228.2.53"
    @port = 21
    @user = "kfhyuser"
    @password = "0QY7rN86taOq"
  end

  def extract_to_redis
    @file = NumRu::NetCDF.open nc_filename
    _var_name = "TMP_2mb"
    _var = @file.var _var_name
    _var.get.each_with_index do |_var_value, _index|
      _lon_index = 
      _lat_index = 
      _redis_key = "#{_var_name}_#{time}"
      $redis.hset _redis_key, _lon_index
    end
  end

  
end