class UploadController < ApplicationController
  def index
  end
  
  def new
  end

  def uploadFile
       df = DataFile.new(strtrama: "ok")
       df.save(params[:upload])
       
      render html: df.tramaoriginal(df.rutafile()).html_safe
      #render plain: df.retornartrama("edgar")
      #render plain: "hola"
  end    
  
end
