#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'

cgi = CGI.new
cookies = cgi.cookies

begin
  is_reset = cgi['reset']
  man_janken = cgi['janken'].to_i
  num_man_win = (cookies["man_win"][0] || 0).to_i
  num_man_lose = (cookies["man_lose"][0] || 0).to_i
  num_man_draw = (cookies["man_draw"][0] || 0).to_i


  computer_janken = rand(3)

  hashdayo = Hash.new("")
  hashdayo['0'] = "Rock"
  hashdayo['1'] = "Scissors"
  hashdayo['2'] = "Paper"


  janken_result = (man_janken-computer_janken+3)%3 #modで勝敗が綺麗に場合分けされることに着目
  #p man_janken, computer_janken
  case janken_result
  when 0
    result_str = "DRAW"
    num_man_draw += 1
  when 1
    result_str = "YOU LOSE"
    num_man_lose += 1
  when 2
    result_str = "YOU WIN"
    num_man_win += 1
  else
    p "WTF!!??"
  end


  cookie_win = CGI::Cookie.new("name" => "man_win", "value" => num_man_win.to_s)
  cookie_lose = CGI::Cookie.new("name" => "man_lose", "value" => num_man_lose.to_s)
  cookie_draw = CGI::Cookie.new("name" => "man_draw", "value" => num_man_draw.to_s)

  print cgi.header("type" => "text/html", "charset" => "utf-8","cookie" => [cookie_win,cookie_lose,cookie_draw])


print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>じゃんけんけっか</title>
</head>
<body>
<h1>じゃんけん</h1>
EOS

#p cgi["what"]

printf("YOU : " + hashdayo[man_janken.to_s] + "<br>")
printf("COMPUTER : " + hashdayo[computer_janken.to_s] + "<br>")



print <<EOS
<br>
<h5>#{result_str}</h5>
<p>現在の勝敗 : #{num_man_win}勝 #{num_man_lose}敗 #{num_man_draw}分け</p>

<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/janken_cookie.rb" >もっかい勝負</a>

<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/janken_cookie.rb" method="post" >
<p><input type="submit" name = "isreset" value="じゃんけん結果をリセットする" ></p>
</body>
</html>
EOS



rescue => ex
  puts ex.message
  puts ex.backtrace
end
