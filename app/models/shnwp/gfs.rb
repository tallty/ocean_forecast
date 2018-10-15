class Shnwp::Gfs
  include Shnwp

  def initialize
    @server = "10.228.118.118"
    @port = 21
    @passive = true
    @user = "unimet"
    @password = "KKcBh9VhivM"
    @local_dir = "./public/gfs"
    @remote_dir = "/GFS"

    @file_pattern = "gfs*"
  end

end
