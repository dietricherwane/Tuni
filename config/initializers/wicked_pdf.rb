#WICKED_PDF = {
  #:wkhtmltopdf => '/usr/local/bin/wkhtmltopdf',
  #:layout => "pdf.html",
#  :exe_path => Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s
#}

WickedPdf.config = {
#for my local machine
  :exe_path => Rails.root.join('bin', 'wkhtmltopdf-i386').to_s, 
  #:exe_path => Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s,
	:orientation => 'Landscape',
	:lowquality => false

# for heroku
  #:exe_path => Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s 
}
