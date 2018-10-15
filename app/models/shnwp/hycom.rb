class Shnwp::Hycom
  include Shnwp

  def initialize
    @server = "10.228.118.118"
    @port = 21
    @passive = true
    @user = "unimet"
    @password = "KKcBh9VhivM"
    @local_dir = "./public/hycom"
    @remote_dir = "/HYCOM"

    @file_pattern = "hycom*"
  end
end
