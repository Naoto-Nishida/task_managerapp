#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'
cgi = CGI.new

begin

  print cgi.header("text/html; charset=utf-8")
  data = open("vote_result.txt", "a:UTF-8")
  data.flock(File::LOCK_EX)

  num_of_choice = cgi["hidden"]

for i in 0...num_of_choice.to_i do
  tmp  = cgi[i.to_s]
  if not tmp.empty?
    data.write(tmp + "\n")
  end
end
data.flock(File::LOCK_UN)
data.close

print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>enquete_form</title>
</head>
<body>
<h2>投票ありがとナス！！</h2>

<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/view_result.rb" >投票結果を見る</a>
<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/enquete_form.rb" >投票に戻る</a>
</body>
</html>
EOS


rescue => ex
  puts ex.message
  puts ex.backtrace
end
