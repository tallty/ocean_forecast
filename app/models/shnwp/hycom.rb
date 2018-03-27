class Shnwp::Hycom
  include Shnwp

  def initialize
    @server = "psdata.shnwp.org"
    @port = 21
    @passive = true
    @user = "unimet"
    @password = "KKcBh9VhivM"
    @local_dir = "./public/hycom"
    @remote_dir = "/HYCOM"

    @file_pattern = "hycom*"
  end
end
