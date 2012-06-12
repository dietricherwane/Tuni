class PdfCreationsController < ApplicationController

	def tst
		respond_to do |format|
      format.html { render(:html => "tst", :layout => false) }
      format.pdf { render(:pdf => "tst", :footer => { :right => '[page] / [topage]' }, :layout => false) }
    end
	end

end
