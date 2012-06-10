class PdfCreationsController < ApplicationController

	def tst
		respond_to do |format|
      format.html { render :layout => false }
      format.pdf { render(:pdf => "tst", :layout => false) }
    end
	end

end
