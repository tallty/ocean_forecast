class Ocean::NabcHfradarsController < ApplicationController

  def index
    render json: get_data_json(params[:type], params[:date])
  end

  private

    def get_data_jaon(type, date)
      date = Date.parse params[:date] rescue Time.zone.today
      data_type = (data_types & params[:type]).first || return { error: "data type is error: #{data_type}"}
      
      files_json = Dir[ File.join(date_dir(data_type, date), "*#{file_type}" ].map do |path|
        {
          filename: File.basename(path),
          url: "#{url_base}#{path.split('/public/').last}"
        }
      end
    end

    def local_dir
      './public/nabc_hfradar/'  
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
      %q{
        usegc_1km usegc_2km usegc_6km 
        uswc_500m uswc_1km  uswc_2km  uswc_6km   
        ushi_1km  ushi_2km  ushi_6km  
        prvi_2km  prvi_6km 
      }
    end
end
