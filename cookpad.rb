#URLにアクセスする為のライブラリの読み込み
require 'open-uri'
#Nokogiriライブラリの読み込み
require 'nokogiri'

# スクレイピング先のURL
#url = 'http://matome.naver.jp/tech'
#url = 'http://cookpad.com/search/%E3%81%AB%E3%82%93%E3%81%98%E3%82%93%E3%80%80%E3%81%9F%E3%81%BE%E3%81%AD%E3%81%8E?order=popularity'

def get_recipe(food1, food2, food3)
  
  foodsearchlist = "#{food1} #{food2} #{food3}"
  url = URI.escape("http://cookpad.com/search/#{foodsearchlist}")

  charset = nil
  html = open(url) do |f|
    charset = f.charset # 文字種別を取得
    f.read # htmlを読み込んで変数htmlに渡す
  end

  # htmlをパース(解析)してオブジェクトを作成
  doc = Nokogiri::HTML.parse(html, nil, charset)

  array = Array.new
  
  doc.xpath('//*[@class="recipe-preview"]').each do |node|
    
    title = node.css('.recipe-title').inner_text
    recipe_url = "http://cookpad.com" + node.css('a').attribute('href').value
    img_url = node.css('img').attribute('src').value
    material = node.css('.material').inner_text
    
    material.gsub!(/\n/, "")
    
    array << {title: title, recipe_url: recipe_url, img_url: img_url, material: material}
    
  end
  return array
  
end

answer1 = get_recipe("こんにゃく", "たまねぎ", "おかず")
answer2 = get_recipe("かぼちゃ", "とりにく", "おかず")

answer = answer1 + answer2
p answer
