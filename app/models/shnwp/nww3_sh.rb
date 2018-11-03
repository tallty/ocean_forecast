class Shnwp::Nww3Sh
  include Shnwp

  def initialize
    @server = "10.228.118.118"
    @port = 21
    @passive = true
    @user = "unimet"
    @password = "KKcBh9VhivM"
    @local_dir = "./public/nww3"
    @remote_dir = "/WW3-SH"

    @file_pattern = "sims_nww3*"
  end

end
