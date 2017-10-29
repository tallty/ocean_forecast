class Ocean::NabcHfradarsController < ApplicationController

  def index
    render json: get_data_json
  end

  private

    def get_data_json
      date = Date.parse(params[:date]) rescue Time.now.gmtime.to_date
      data_type = (data_types & Array(params[:type])).first
      return({ code: '100002', msg: "invalid type : #{params[:type]}" }) unless data_type
      
      files = Dir[ File.join(date_dir(data_type, date), "*#{file_type}") ].sort.map do |path|
        {
          filename: File.basename(path),
          url: "#{url_base}#{path.split('/public/').last}"
        }
      end

      {
        code: '1',
        msg: msg_trans(data_type),
        data: {
          type: data_type,
          date: date.to_s,
          files: files,
        }
      }
    end

    def local_dir
      NABC::Hfradar::LOCAL_DIR
    end

    def file_type
      '.nc'
    end

    def url_base
      'http://61.152.122.112:8080/'
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

    def msg_trans type
      case type
      when /usegc_.*/
        'US East Coast and Gulf of Mexico HF Radar data '
      when /uswc_.*/
        'US West Coast HF Radar data'
      when /ushi_.*/
        'US Hawaii HF Radar data'
      when /prvi_.*/
        'Puerto Rico/Virgin Islands HF Radar data'
      else
        ''
      end
    end
end
