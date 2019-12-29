#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'

cgi = CGI.new
cookies = cgi.cookies
begin

  if cgi['isreset'].empty?
    num_man_win = (cookies["man_win"][0] || 0).to_i
    num_man_lose = (cookies["man_lose"][0] || 0).to_i
    num_man_draw = (cookies["man_draw"][0] || 0).to_i
  else
    num_man_win = 0
    num_man_lose = 0
    num_man_draw = 0
  end

  cookie_win = CGI::Cookie.new("name" => "man_win", "value" => num_man_win.to_s)
  cookie_lose = CGI::Cookie.new("name" => "man_lose", "value" => num_man_lose.to_s)
  cookie_draw = CGI::Cookie.new("name" => "man_draw", "value" => num_man_draw.to_s)


print cgi.header("type" => "text/html", "charset" => "utf-8","cookie" => [cookie_win, cookie_lose, cookie_draw])


print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>じゃんけんしよう</title>
</head>
<body>
<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/judge_cookie.rb" method="post" >
<h1>じゃんけん</h1>
EOS

printf("現在の勝敗 : %s勝 %s敗 %s分け <br><br>\n",num_man_win,num_man_lose,num_man_draw)
#printf(is_reset + "AAAA")

print <<EOS
<p><input type="radio" name="janken" value='0'>Rock</p>
<p><input type="radio" name="janken" value='1'>Scissors</p>
<p><input type="radio" name="janken" value='2'>Paper</p>
<p><input type="submit" value="Battle!!" ></p>



</body>
</html>
EOS


rescue => ex
  puts ex.message
  puts ex.backtrace
end
