# PDFKit.configure do |config|
#  # config.wkhtmltopdf = '/home/ali/.rvm/gems/ruby-2.2.1/bin/wkhtmltopdf'
#  config.default_options[:ignore_load_errors] = true
# end

WickedPdf.config = {
  exe_path: '/usr/local/bin/wkhtmltopdf'
}