#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'
require 'cgi/session'
cgi = CGI.new
session = CGI::Session.new(cgi)

begin

  if cgi['isreset'].empty?
    session['man_win'] = (session['man_win'] || 0).to_i
    session['man_lose'] = (session['man_lose'] || 0).to_i
    session['man_draw'] = (session['man_draw'] || 0).to_i
  else
    session['man_win'] = 0
    session['man_lose'] = 0
    session['man_draw'] = 0
  end


print cgi.header("text/html; charset=utf-8")



print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>じゃんけんしよう</title>
</head>
<body>
<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/judge_session.rb" method="post" >
<h1>じゃんけん</h1>
EOS

printf("現在の勝敗 : %s勝 %s敗 %s分け <br><br>\n",session['man_win'],session['man_lose'],session['man_draw'])
#printf(cgi["hidden"] + "AAAA")

print <<EOS
<p><input type="radio" name="janken" value='0'>Rock</p>
<p><input type="radio" name="janken" value='1'>Scissors</p>
<p><input type="radio" name="janken" value='2'>Paper</p>
<p><input type="submit" value="Battle!!" ></p>



</body>
</html>
EOS

session.close

rescue => ex
  puts ex.message
  puts ex.backtrace
  session.close
end
