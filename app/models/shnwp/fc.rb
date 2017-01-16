class Shnwp::Fc
  include Shnwp

  def initialize
    @server = "10.228.18.61"
    @port = 21
    @passive = true
    @user = "unimet"
    @password = "123456"
    @local_dir = "../sh_weather/public/fc"
    @remote_dir = "/FC"

    @file_pattern = "*json"
  end



end
