require 'net/ftp'

module Net
  class FTP
    def makepasv
      if @sock.peeraddr[0] == 'AF_INET'
        host, port = parse229(sendcmd('EPSV'))
      else
        host, port = parse227(sendcmd('EPSV'))
      end
      return host, port
    end
  end
end

module FtpConcern
  module ClassMethods
    
  end
  
  module InstanceMethods
    def connect
      @connection = Net::FTP.new
      @connection.connect(@server, @port)
      @connection.passive = @passive || false
      @connection.resume = true
      @connection.makepasv if @epsv
      if @user.present?
        @connection.login(@user, @password)
      else
        @connection.login
      end
      @connection
    end

    def close
      @connection.close if @connection
      @connection = nil
    end

    def closed?
      @connection.nil? || @connection.closed?
    end

    def ls file_pattern=nil
      @connection.nlst(file_pattern)
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end