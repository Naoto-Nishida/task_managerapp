#!/usr/bin/env ruby
# encoding: UTF-8
require 'sqlite3'
require 'cgi'
require 'cgi/session'
require "cgi/escape"
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

#add_data.rbからデータが渡ってくる
subject = CGI.escapeHTML(cgi["subject"]) #エスケープ処理でインジェクション対策
detail = CGI.escapeHTML(cgi["detail"])
howmany = CGI.escapeHTML(cgi["howmany"])
whatkind = CGI.escapeHTML(cgi["whatkind"])
#この辺参考に
#https://qiita.com/scivola/items/b2d749a5a720f9eb02b1


new_task = []
new_task_sequence = []

db.transaction(){ #add_data.rbから渡ってきたデータを元に、DBにTasksおよびSequenceのデータを作成。
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

  new_task = db.execute("SELECT * FROM Tasks WHERE task_id = ?;", task_id).first
  new_task_sequence = db.execute("SELECT * FROM Sequence WHERE task_id = ?;", task_id).first
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
-----------------------<br>
#{new_task[1]}<br>
#{new_task[2]}<br>
NEXT TIME : #{new_task_sequence[2].slice(0,11)}<br>
-----------------------<br>
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
