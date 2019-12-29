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

if session['user'].nil? #ユーザ登録機能を付けたいが、PHPのようにPDOなど便利なものもなく、Railsも使っていないので簡易的なものにしてある。セキュリティ対策としてはあまり強くない。
  #session記録がない場合、DBのUserに半ば強制的に登録をさせて固有のユーザIDを登録し、後でユーザ名を好みで変えてもらう仕組み。
  db.transaction(){
    db.execute("INSERT INTO User (name, experience_point) VALUES(\"SOMEONE\", 0);")
    session['user'] = db.execute("SELECT user_id FROM User where rowid = last_insert_rowid();").first.first
  }
else
  session['user'] = session['user']
end

done_task = cgi["done_task"] #今のところ複数のタスクを同時に消化させる機能はついてない。ひとつづつ。
subject = cgi["subject"]
detail = cgi["detail"]
howmany = cgi["howmany"]
whatkind = cgi["whatkind"]
p done_task


new_task_inquestion = []

db.transaction(){
  #select : [[]]の形で取り出される
  # should make a change on the user_id. it should be changible
  db.execute("INSERT INTO Tasks (subject,detail,howmany, insert_time, user_id) VALUES(?, ?, ?, datetime('now', 'localtime'), ?);", subject, detail, howmany, session['user'])
  #maybe we should get the task_id and specify it below.
  task_id = db.execute("SELECT task_id FROM Tasks WHERE rowid = last_insert_rowid();").first.first
  case whatkind #task_idに紐付けて細かい情報を保存。
  when 0 #everyday
    db.execute("INSERT INTO Sequence(task_id,whatkind, next_time, num_th) VALUES(?,?, datetime('now', '+33 hours'), 1);",task_id, whatkind)
  when 1 #everyweek
    db.execute("INSERT INTO Sequence(task_id,whatkind, next_time, num_th) VALUES(?,?, datetime('now', '+177 hours'), 1);",task_id, whatkind)
  when 2 #everymonth
    db.execute("INSERT INTO Sequence(task_id,whatkind, next_time, num_th) VALUES(?,?, datetime('now', '+1 months'), 1);",task_id, whatkind)
  else #forgetting curve
    db.execute("INSERT INTO Sequence(task_id,whatkind, next_time, num_th) VALUES(?, ?, datetime('now', '+1 days'), 1);",task_id, whatkind)
  end
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
