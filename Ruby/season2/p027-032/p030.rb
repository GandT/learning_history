# -*- coding: utf-8 -*-
=begin
　2017.5.2
　eachメソッド
=end


waka = 
[
["秋の田の","かりほの庵の","苫をあらみ","わが衣手は","露にぬれつつ"],
["春すぎて","夏来にけらし","白妙の","衣ほすてふ","天の香具山"],
["あしびきの","山鳥の尾の","しだり尾の","ながながし夜を","ひとりかも寝む"],
["田子の浦に","うち出でてみれば","白妙の","富士の高嶺に","雪は降りつつ"],
["奥山に","紅葉踏みわけ","鳴く鹿の","声きく時ぞ","秋は悲しき"]
]

waka.each do |w|
  p w
  w.each do |f|
    print f, " "
  end
  print "\n"
end
