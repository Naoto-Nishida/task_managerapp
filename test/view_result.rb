#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'
cgi = CGI.new

begin

print cgi.header("text/html; charset=utf-8")

hashdayo = Hash.new(0)
question = ""
isum = 0
open("question.txt", "r:UTF-8") do |io|
  question = io.gets.chomp
end
open("vote_result.txt", "r:UTF-8") do |io|
  while line = io.gets
    line = line.chomp
    hashdayo[line] += 1
    isum += 1
  end
end
#puts question,choices
print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>view_result</title>
</head>
<body>
<h1>投票結果</h1>
<h2>#{question}</h2>
EOS

printf("総投票数 : %d <br><br>\n",isum)

hashdayo.sort.to_a.each do |idx|
  printf("%s : %d <br>\n", idx[0], idx[1])
end

print <<EOS
<br>
<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/enquete_form.rb" >投票に戻る</a>

</body>
</html>
EOS

rescue => ex
  puts ex.message
  puts ex.backtrace
end
