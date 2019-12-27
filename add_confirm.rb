#!/usr/bin/env ruby
# encoding: UTF-8
require 'sqlite3'
require 'cgi'
require 'cgi/session'
cgi = CGI.new
session = CGI::Session.new(cgi)

begin

session['user'] = (session['user'] || 1) #のちのちいじる必要ある。固有のユーザIDを付加したい。
print cgi.header("text/html; charset=utf-8")

db = SQLite3::Database.new("Indepedence.db")

done_task = cgi["done_task"] #今のところ複数のタスクを同時に消化させる機能はついてない。ひとつづつ。
subject = cgi["subject"]
detail = cgi["detail"]
howmany = cgi["howmany"]
whatkind = cgi["whatkind"]
p done_task

#
#insert into

db.transaction(){
  #[[]]の形で取り出される
  # should make a change on the user_id. it should be changible
  db.execute("INSERT INTO Tasks (subject,detail,howmany, insert_time, user_id) VALUES(?, ?, ?, datetime('now', 'localtime'), 1);", subject, detail, howmany)
  #maybe we should get the task_id and specify it below.
  db.execute("INSERT INTO Sequence(whatkind, next_time, num_th) VALUES(?, ?, 1);", whatkind, )
  #db.execute("INSERT INTO Sequence(task_id,whatkind, next_time, num_th) VALUES(2, 1, "2020-01-01 12:00:00", 1);", subject, detail, howmany)


  new_task_inquestion = db.execute("SELECT * FROM Sequence WHERE task_id = ?;", done_task)
  new_task_inquestion = new_task_inquestion[0]
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
Your task has been updated.<br>
<br>
#{new_task_inquestion}
<br>
<br>
<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/view_task.rb" >View tasks</a>
</body>
</html>

EOF
session.close
rescue => ex
  puts ex.message
  puts ex.backtrace
end
