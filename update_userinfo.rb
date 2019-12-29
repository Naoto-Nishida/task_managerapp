#!/usr/bin/env ruby
# encoding: UTF-8
require 'sqlite3'
require 'cgi'
require 'cgi/session'
cgi = CGI.new
session = CGI::Session.new(cgi)

begin

print cgi.header("text/html; charset=utf-8")

db = SQLite3::Database.new("Indepedence.db")

if session['user'].nil? or (!session['user'].integer?)#ユーザ登録機能を付けたいが、PHPのようにPDOなど便利なものもなく、Railsも使っていないので簡易的なものにしてある。
  #session記録がない場合、DBのUserに半ば強制的に登録をさせて固有のユーザIDを付加し、後でユーザ名を好みで変えてもらう仕組み。
  #簡易的にインジェクションに対してのセキュリティ機能も実装してある。sessionの値に不正な値を入れてインジェクションしようとしてもこの節で整数に書き換えられるしくみ。
  db.transaction(){
    db.execute("INSERT INTO User (name, experience_point) VALUES(\"SOMEONE\", 0);")
    session['user'] = db.execute("SELECT user_id FROM User where rowid = last_insert_rowid();").first.first
  }
else
  session['user'] = session['user']
end

username = CGI.escapeHTML(cgi["username"]) #インジェクション対策


user_inquestion = []

db.transaction(){
  #[[]]の形で取り出される. #User: {user_id, name, experience_point}
  #user_inquestion = db.execute("SELECT * FROM User WHERE user_id = ?;", session['user']).first
  db.execute("UPDATE User SET name = ? WHERE user_id = ?;", username, session['user'])

}

print <<EOF
<html>
<head>
<meta charset="UTF-8">
<title>update</title>
<head>
<body>
thanks.<br>
<br>
Your name has been updated.<br>
<br>
<p1> HELLO!! #{username} !!</p1>
<br>
<br>
<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/view_task.rb" >View your tasks</a>
</body>
</html>

EOF
session.close
rescue => ex
  puts ex.message
  puts ex.backtrace
end
