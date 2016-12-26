class Shnwp::Fc
  include Shnwp

  def initialize
    @server = "59.110.141.81"
    @port = 21
    @passive = true
    @user = "ftptest"
    @password = "Kjfwzx2016"
    @local_dir = "../sh_weather/public/fc"
    @remote_dir = "/FC"

    @file_pattern = "*json"
  end



end
