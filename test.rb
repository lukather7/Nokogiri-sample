require 'open-uri'
require 'nokogiri'
require 'nkf'
require 'awesome_print'
require 'uri'

# スクレイピング先のURL
url = 'rds.html'
url = 'rds1.html'
url = "http://www.thr.mlit.go.jp/road/koutsu/Michi-no-Eki/index.html"


p URI.parse(url).merge("aomori/ao01.html").to_s

exit

charset = "Shift_JIS"
html = open(url) do |f|
#  charset = f.charset # 文字種別を取得
#  f.read.gsub(/\r\n/, "\n") # htmlを読み込んで変数htmlに渡す
  f.each_line {|line| p line }
end

  doc = Nokogiri::HTML.parse(html, nil, charset)
#  doc.each {|e|
#    p e
#  }