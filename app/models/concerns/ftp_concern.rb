require 'net/ftp'

module FtpConcern
  module ClassMethods
    
  end
  
  module InstanceMethods
    def connect
      @connection = Net::FTP.new
      @connection.connect(@server, @port)
      @connection.passive = @passive || false
      @connection.resume = true
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