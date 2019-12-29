#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'
cgi = CGI.new

begin

print cgi.header("text/html; charset=utf-8")

choices =[]
question = ""
open("question.txt", "r:UTF-8") do |io|
  question = io.gets.chomp
  while line = io.gets
    line = line.chomp
    choices.push(line)
  end
end
#puts question,choices
print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>enquete_form</title>
</head>
<body>
<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/vote.rb" method="post" >
<h1>投票システム</h1>
<h2>#{question}</h2>
EOS

choices.each_with_index do |choice, i|
  print <<EOS
	 <p><input type="checkbox" name=#{i.to_s} value=#{choice}>#{choice}</p>
EOS
end

print <<EOS
  <p><input type="hidden" name="hidden" value=#{choices.length}></p>
	<p><input type="submit" value="submit"></p>
	<p><input type="reset" value="reset"></p>
</form>

<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/view_result.rb" >投票結果を見る</a>

</body>
</html>
EOS

rescue => ex
  puts ex.message
  puts ex.backtrace
end
