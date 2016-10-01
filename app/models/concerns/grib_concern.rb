module GribConcern
  module ClassMethods
    
  end
  
  module InstanceMethods
    def convert_grib_to_netcdf grib_filename
      nc_filename = "#{grib_filename}.nc"
      system grib_filename -netcdf nc_filename
      nc_filename
    end

    def extract_to_redis var
      # file = 
    end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end