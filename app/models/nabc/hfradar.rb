class NABC::Hfradar
  # National Data Buoy Center HF Radar
  #
  # Filename: 
  #   hfradar_usegc_1km   US East Coast and Gulf of Mexico 1km resolution HF Radar data 
  #   hfradar_usegc_2km   US East Coast and Gulf of Mexico 2km resolution HF Radar data
  #   hfradar_usegc_6km   US East Coast and Gulf of Mexico 6km resolution HF Radar data
  #   hfradar_uswc_500m   US West Coast 500m resolution HF Radar data
  #   hfradar_uswc_1km    US West Coast 1km resolution HF Radar data
  #   hfradar_uswc_2km    US West Coast 2km resolution HF Radar data
  #   hfradar_uswc_6m     US West Coast 6km resolution HF Radar data
  #   hfradar_ushi_1km    US Hawaii 1km resolution HF Radar data
  #   hfradar_ushi_2km    US Hawaii 2km resolution HF Radar data
  #   hfradar_ushi_6km    US Hawaii 6km resolution HF Radar data
  #   hfradar_prvi_2km    Puerto Rico/Virgin Islands 2km resolution HF Radar data
  #   hfradar_prvi_6km    Puerto Rico/Virgin Islands 6km resolution HF Radar data
  # 
  # Init File List:
  #   http://sdf.ndbc.noaa.gov/thredds/catalog/hfradar/catalog.html

  def initialize
    @local_dir = 'public/http'
  end

  def scan
    groups = get_list.search('tr')[2..-1].map { |ele| line_to_filename ele.content }.group_by { |name| match_filename(name)[2] }  
    new_files = []
    groups.each do |key, names|
      new_files += (names - $redis.smembers("#{key}_downloading") - get_local_file_list(key))
    end

    new_files.each do |filename| 
      name, date, key = match_filename(filename).to_a
      HttpDownloadWorker.perform_async(
        name, key, get_uri(filename), date_dir(key, date)
      ) 
    end
  end

  def get_list
    require 'net/http'
    uri = URI('http://sdf.ndbc.noaa.gov/thredds/catalog/hfradar/catalog.html')
    res = Net::HTTP.get(uri)
    data = Nokogiri::HTML(res)#.search('pre/span').map(&:content)
  end

  def line_to_filename line
    line.split("\r\n").third
  end

  def match_filename filename
    /^(.*)_hfr_(.*)_rtv_uwls_NDBC.nc/.match(filename)
  end

  def local_check_time_scope
    (DateTime.now - 2.day .. DateTime.now).each
  end

  def date_dir key, time
    time = time.to_time
    File.join(@local_dir, key, time.year.to_s, time.month.to_s, time.day.to_s)
  end

  def get_local_file_list key
    local_check_time_scope.map do |date| 
      dir = date_dir(key, date)
      File.exist?(dir) ? Dir.entries(dir).reject { |f| File.directory? f } : []
    end.reduce(:+)
  end

  def get_uri filename
    "http://sdf.ndbc.noaa.gov/thredds/ncss/grid/hfradar/#{filename}?var=DOPx&var=DOPy&var=u&var=v"
  end
end


  # /^(.*)_hfr_(.*)_rtv_uwls_NDBC.nc/.match("201710201700_hfr_usegc_1km_rtv_uwls_NDBC.nc")

  # /^(.*)_hfr_usegc_1km_rtv_uwls_NDBC.nc/.match("201710201700_hfr_usegc_1km_rtv_uwls_NDBC.nc")
  # split("\r\n").third

  # group_by {|x| /^(.*)_hfr_(.*)_rtv_uwls_NDBC.nc/.match(x)[2] }

  # '201710251100_hfr_uswc_6km_rtv_uwls_NDBC.nc'
  # %q{
  # hfradar_201710250300_hfr_uswc_1km_rtv_uwls_NDBC
  # http://sdf.ndbc.noaa.gov/thredds/ncss/grid/hfradar/201710250300_hfr_uswc_1km_rtv_uwls_NDBC.nc?var=DOPx&var=DOPy&var=u&var=v&north=49.9920&west=-130.3600&east=-115.8055&south=30.2500&horizStride=1&time_start=2017-10-25T03%3A00%3A00Z&time_end=2017-10-25T03%3A00%3A00Z&timeStride=1


  # 201710251100_hfr_uswc_6km_rtv_uwls_NDBC.nc
  # http://sdf.ndbc.noaa.gov/thredds/ncss/grid/hfradar/201710251100_hfr_uswc_6km_rtv_uwls_NDBC.nc?var=DOPx&var=DOPy&var=u&var=v&horizStride=1&time_start=2017-10-25T11%3A00%3A00Z&time_end=2017-10-25T11%3A00%3A00Z&timeStride=1
  # http://sdf.ndbc.noaa.gov/thredds/ncss/grid/hfradar/201710251100_hfr_uswc_6km_rtv_uwls_NDBC.nc?var=DOPx&var=DOPy&var=u&var=v&north=49.9920&west=-130.3600&east=-115.8055&south=30.2500&horizStride=1&time_start=2017-10-25T11%3A00%3A00Z&time_end=2017-10-25T11%3A00%3A00Z&timeStride=1
  # }

  # def default_lat_and_lot
  #   {
  #     'uswc_6km' => 'north=49.9920&west=-130.3600&east=-115.8055&south=30.2500'
  #   }
  # end
  # http://sdf.ndbc.noaa.gov/thredds/ncss/grid/hfradar/201710251100_hfr_uswc_6km_rtv_uwls_NDBC.nc?var=DOPx&var=DOPy&var=u&var=v&time_start=2017-10-25T11%3A00%3A00Z&time_end=2017-10-25T11%3A00%3A00Z&timeStride=1
  # http://sdf.ndbc.noaa.gov/thredds/ncss/grid/hfradar/201710251100_hfr_uswc_6km_rtv_uwls_NDBC.nc?var=DOPx&var=DOPy&var=u&var=v
  # "http://sdf.ndbc.noaa.gov/thredds/ncss/grid/hfradar/#{filename}?var=DOPx&var=DOPy&var=u&var=v"