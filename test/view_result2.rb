#!/usr/bin/env ruby
# encoding: UTF-8
require 'sqlite3'
require 'cgi'
cgi = CGI.new

begin

print cgi.header("text/html; charset=utf-8")

db = SQLite3::Database.new("report1024.db")

hashdayo = Hash.new(0)
question = ""
rows = ''
isum = 0

#open("question.txt", "r:UTF-8") do |io|
#  question = io.gets.chomp
#end
db.transaction(){
  question = db.execute("SELECT * FROM question;")
  rows = db.execute("SELECT * FROM votes;")
}
question = question[0][0] #配列からstr型を取り出す。
for line in rows do
  hashdayo[line[0]] += 1 #テーブルのフィールドがひとつしかなくても２次元配列でかえって来るのに注意。
  isum += 1
end
db.close

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

hashdayo.to_a.each do |idx|
  printf("%s : %d <br>\n", idx[0], idx[1])
end

print <<EOS
<br>
<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/enquete_form2.rb" >投票に戻る</a>

</body>
</html>
EOS

rescue => ex
  puts ex.message
  puts ex.backtrace
end
