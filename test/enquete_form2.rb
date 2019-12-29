#!/usr/bin/env ruby
# encoding: UTF-8
require 'sqlite3'
require 'cgi'
cgi = CGI.new

begin

print cgi.header("text/html; charset=utf-8")
db = SQLite3::Database.new("report1024.db")


choices =[]
question = ""

db.transaction(){
  question = db.execute("SELECT * FROM question;")
  choices = db.execute("SELECT * FROM choices")
}
question = question[0][0]
#open("question.txt", "r:UTF-8") do |io|
#  question = io.gets.chomp
#  while line = io.gets
#    line = line.chomp
#    choices.push(line)
#  end
#end
#puts question,choices
print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>enquete_form</title>
</head>
<body>
<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/vote2.rb" method="post" >
<h1>投票システム</h1>
<h2>#{question}</h2>
EOS

choices.each_with_index do |choice, i|
  print <<EOS
	 <p><input type="checkbox" name=#{i.to_s} value=#{choice[0]}>#{choice[0]}</p>
EOS
end

print <<EOS
  <p><input type="hidden" name="hidden" value=#{choices.length}></p>
	<p><input type="submit" value="submit"></p>
	<p><input type="reset" value="reset"></p>
</form>

<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/view_result2.rb" >投票結果を見る</a>

</body>
</html>
EOS

rescue => ex
  puts ex.message
  puts ex.backtrace
end
