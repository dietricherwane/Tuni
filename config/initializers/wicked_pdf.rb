#WICKED_PDF = {
  #:wkhtmltopdf => '/usr/local/bin/wkhtmltopdf',
  #:layout => "pdf.html",
#  :exe_path => Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s
#}

WickedPdf.config = {
  #:exe_path => Rails.root.join('bin', 'wkhtmltopdf-i386').to_s #for my local machine
  :exe_path => Rails.root.join('bin', 'wkhtmltopdf-amd64').to_s # for heroku
}
