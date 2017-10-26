module Noaa
  include FtpConcern

  def processing?
      $redis.get("#{self.class.to_s}#processing").present? 
  end

  def to_datetime_string time
    time.strftime('%Y%m%d%H')
  end
end
