#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'
require 'cgi/session'
cgi = CGI.new
session = CGI::Session.new(cgi)

begin
  is_reset = cgi['reset']
  man_janken = cgi['janken'].to_i
  session['man_draw'] = (session['man_draw'] || 0).to_i
  session['man_lose'] = (session['man_lose'] || 0).to_i
  session['man_win'] = (session['man_win'] || 0).to_i

  computer_janken = rand(3)

  hashdayo = Hash.new("")
  hashdayo['0'] = "Rock"
  hashdayo['1'] = "Scissors"
  hashdayo['2'] = "Paper"

print cgi.header("text/html; charset=utf-8")

print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>じゃんけんけっか</title>
</head>
<body>
<h1>じゃんけん</h1>
EOS

#p cgi["what"].empty?

printf("YOU : " + hashdayo[man_janken.to_s] + "<br>")
printf("COMPUTER : " + hashdayo[computer_janken.to_s] + "<br>")

janken_result = (man_janken-computer_janken+3)%3 #modで勝敗が綺麗に場合分けされることに着目
#p man_janken, computer_janken
case janken_result
when 0
  result_str = "DRAW"
  session['man_draw'] += 1
when 1
  result_str = "YOU LOSE"
  session['man_lose'] += 1
when 2
  result_str = "YOU WIN"
  session['man_win'] += 1
else
  result_str = "WTF!!??"
end

#printf("現在の勝敗 : %s勝 %s敗 %s分け <br><br>\n",session['man_win'],session['man_lose'],session['man_draw'])



print <<EOS
<br>
<h5>#{result_str}</h5>
<p>現在の勝敗 : #{session['man_win']}勝 #{session['man_lose']}敗 #{session['man_draw']}分け</p>

<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/janken_session.rb" >もっかい勝負</a>
<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/janken_session.rb" method="post" >
<p><input type="submit" value="じゃんけん結果をリセットする" name = "isreset"></p>
</body>
</html>
EOS

session.close

rescue => ex
  puts ex.message
  puts ex.backtrace
  session.close
end
