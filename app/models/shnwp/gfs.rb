class Shnwp::Gfs
  include Shnwp

  def initialize
    @server = "psdata.shnwp.org"
    @port = 21
    @passive = true
    @user = "unimet"
    @password = "KKcBh9VhivM"
    @local_dir = "./public/gfs"
    @remote_dir = "/GFS"

    @file_pattern = "gfs*"
  end

end
