class Shnwp::Cw
  include Shnwp

  def initialize
    @server = "59.110.141.81"
    @port = 21
    @passive = true
    @epsv = true
    @user = "ftptest"
    @password = "Kjfwzx2016"
    @local_dir = "../sh_weather/public/cw"
    @remote_dir = "/CW"

    @file_pattern = "*json"
  end



end
