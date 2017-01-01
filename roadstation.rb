require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'nkf'
require 'awesome_print'

def get_url(key)
    url_hash = {
        北海道: "http://www.hkd.mlit.go.jp/zigyoka/z_doro/Michi-no-Eki/index.html",
        東北: "http://www.thr.mlit.go.jp/road/koutsu/Michi-no-Eki/index.html",
        関東:"http://www.ktr.mlit.go.jp/honkyoku/road/Michi-no-Eki_knt.html",
        北陸:"http://www.hrr.mlit.go.jp/road/Michi-no-Eki/index_hkr.html",
        中部:"http://www.cbr.mlit.go.jp/michinoeki/Michi-no-Eki/index_cyb.html",
        近畿:"http://www.kkr.mlit.go.jp/road/Michi-no-Eki/index.html",
        中国:"http://www.cgr.mlit.go.jp/chiki/doyroj/michinoeki/Michi-no-Eki/index.html",
        四国:"http://www.skr.mlit.go.jp/road/Michi-no-Eki/index_skk.html",
        九州・沖縄:"http://www.qsr.mlit.go.jp/n-michi/michi_no_eki/Michi-no-Eki/Michi-no-Eki_ksy_index.html"
    }
    
    url_hash[key.to_sym]
end

def get_roadstation_list(region)
  # スクレイピング先のURL
  url = get_url(region)
  base_url = URI.parse(url)
  
  #国交省四国地方整備局が国外からの接続を遮断しているため
  # railsの場合はアプリケーション直下にファイルを配置すること
  if (region == "四国")
    url = "index_skk.html"
  end
  
  charset = "Shift_JIS"
  html = open(url) do |f|
#    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end
  
  
  # htmlをパース(解析)してオブジェクトを作成
  doc = Nokogiri::HTML.parse(html, nil, charset)
  
  roadstation = Array.new
  cssclass = "j10" 
  cssclass = "MsoNormalTable" if (region == "北陸")
  doc.xpath(%Q!//table[@class="#{cssclass}" and @border="1"]!).each do |tnode|
    index = 0
    array = Array.new
    tnode.xpath('.//tr').each do |trnode|
      if (index >= 2)
        array = Array.new if ((index % 2) == 0)
        trindex = 0
        trnode.xpath('.//td').each do |td|
          
          array << td.inner_text.gsub(/[\s\r\n]/, "")
          array.pop if (region == "中部") && (trindex == 0)
          if (region != "中部" && trindex == 1) || (region == "中部" && trindex == 2)
# =>      中部地区のテーブルのレイアウトがイレギュラーのため対応
# =>      2017年4月移行変更された場合上の3行が2行で良いかもしれない
#          array << td.inner_text.gsub(/[\s\r\n]/, "")
#          if (trindex == 1) 
            if (td.css('a').count > 0)
              array << td.css('a').attribute('href').value
            else
              array << ""
            end
          end
          trindex += 1
        end
        if ((index % 2) == 1)
          roadstation << {systemname: array[0], name: array[1], url: base_url.merge(array[2]).to_s, 
                          address: array[3], road: array[4], tel: array[5], status: array[6],
                          infodevice: array[7], store: array[8], restrant: array[9], 
                          park: array[10], pd_toilet: array[11], pd_parking: array[12],
                          ev_charge: array[13], comment: array[14]}
        elsif ( array[6] == "整備中" )
          roadstation << {systemname: array[0], name: array[1], url: base_url.merge(array[2]),
                          address: array[3], road: array[4], tel: array[5], status: array[6]}
        end
  
      end
      index += 1
    end
  end
  roadstation
end


if __FILE__ == $0


#r_station = get_roadstation_list("九州・沖縄")
r_station = get_roadstation_list("四国")
p r_station

end