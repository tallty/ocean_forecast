class Ocean::NabcHfradarsController < ApplicationController

  def index
    render json: get_data_json(params[:type], params[:date])
  end

  private

    def get_data_json(type, date)
      date = Date.parse params[:date] rescue Time.zone.today
      data_type = (data_types & Array(params[:type])).first
      return({ error: "data type is error: #{data_type}"}) unless data_type
      
      Dir[ File.join(date_dir(data_type, date), "*#{file_type}") ].map do |path|
        {
          filename: File.basename(path),
          url: "#{url_base}#{path.split('/public/').last}"
        }
      end
    end

    def local_dir
      NABC::LOCAL_DIR
    end

    def file_type
      '.nc'
    end

    def url_base
      'http://61.152.122.112:8080/ocean/'
    end

    def date_dir key, date
      File.join(local_dir, key, date.year.to_s, date.month.to_s, date.day.to_s)
    end

    def output_url path
      "http://61.152.122.112:8080/ocean//"
    end

    def data_types
      %w{
        usegc_1km usegc_2km usegc_6km 
        uswc_500m uswc_1km  uswc_2km  uswc_6km   
        ushi_1km  ushi_2km  ushi_6km  
        prvi_2km  prvi_6km 
      }
    end
end
