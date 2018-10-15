class Shnwp::Nww3
  include Shnwp

  def initialize
    @server = "10.228.118.118"
    @port = 21
    @passive = true
    @user = "unimet"
    @password = "KKcBh9VhivM"
    @local_dir = "./public/nww3"
    @remote_dir = "/WW3"

    @file_pattern = "nww3*"
  end
end
