class Shnwp::Nww3
  include Shnwp

  def initialize
    @server = "psdata.shnwp.org"
    @port = 21
    @passive = true
    @user = "unimet"
    @password = "KKcBh9VhivM"
    @local_dir = "./public/nww3"
    @remote_dir = "/NWW3"

    @file_pattern = "nww3*"
  end
end
