class PsdatasController < ApplicationController
  before_action :set_psdata, only: [:show, :update, :destroy]

  respond_to :json

  def index
    data_type = params[:type]
    date_string = params[:date] || Time.zone.today.to_s
    render json: Shnwp.get_data_json(data_type, date_string)
  end

  def show
    respond_with(@psdata)
  end

  def create
    @psdata = Psdatas.new(psdata_params)
    @psdata.save
    respond_with(@psdata)
  end

  def update
    @psdata.update(psdata_params)
    respond_with(@psdata)
  end

  def destroy
    @psdata.destroy
    respond_with(@psdata)
  end

  private
    def set_psdata
      @psdata = Psdatas.find(params[:id])
    end

    def psdata_params
      params[:psdata]
    end
end
