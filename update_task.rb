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

done_task = CGI.escapeHTML(cgi["done_task"])

task_inquestion = []
new_task = []
new_task_sequence = []

db.transaction(){
  #[[]]の形で取り出される. Sequence:{task_id, whatkind, next_time, num_th}
  task_inquestion = db.execute("SELECT * FROM Sequence WHERE task_id = ?;", done_task).first
  case task_inquestion[1]
  when 0 then #毎日習慣.JST+9 hours + 24hours
    db.execute("UPDATE Sequence SET next_time = datetime('now', '+33 hours'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
  when 1 then #毎週習慣JST + 9hours + 24*7hours. daysにはしづらい。
    db.execute("UPDATE Sequence SET next_time = datetime('now', '+177 hours'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
  when 2 then #毎月習慣
    db.execute("UPDATE Sequence SET next_time = datetime('now', '+1 months'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
  else #忘却曲線に沿った習慣
    case task_inquestion[3] #datetime関数の時間シフトのオプションがプレイスホルダーに対応してないっぽいので。。。
    when 1 then
      db.execute("UPDATE Sequence SET next_time = datetime('now', '+3 days'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
    when 2 then
      db.execute("UPDATE Sequence SET next_time = datetime('now', '+7 days'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
    when 3 then
      db.execute("UPDATE Sequence SET next_time = datetime('now', '+14 days'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
    when 4 then
      db.execute("UPDATE Sequence SET next_time = datetime('now', '+30 days'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
    when 5 then
      db.execute("UPDATE Sequence SET next_time = datetime('now', '+60 days'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
    when 6 then
      db.execute("UPDATE Sequence SET next_time = datetime('now', '+90 days'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
    when 7 then
      db.execute("UPDATE Sequence SET next_time = datetime('now', '+120 days'), num_th = ? WHERE task_id = ?;", (task_inquestion[3] + 1).to_s, done_task)
    else
      task_inquestion[3] = 100 #バグ取り。エラー処理でタスクをdoneにする。
    end
  end

  new_task = db.execute("SELECT * FROM Tasks WHERE task_id = ?;", done_task).first
  new_task_sequence = db.execute("SELECT * FROM Sequence WHERE task_id = ?;", done_task).first
}

#if the reccursion time of the task reaches its goal
if new_task[3] <= new_task_sequence[3]
  db.transaction(){
    db.execute("UPDATE Tasks SET done = 1 WHERE task_id = ?;", done_task)
    tmp_exp = db.execute("SELECT experience_point FROM User WHERE user_id = ?", session['user']).first.first
    db.execute("UPDATE User SET experience_point = ? WHERE user_id = ?", tmp_exp + new_task[3]*10, session['user']) #反復回数分*10のポイントがつく
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
  Your task has reached its given goal.<br>
  <br>
  -----------------------<br>
  #{new_task[1]}<br>
  #{new_task[2]}<br>
  -----------------------<br>
  You got a exp : #{new_task[3]*10} points.<br>
  <br>
  <br>
  <a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/view_task.rb" >View your tasks</a>
  </body>
  </html>

EOF
else #if the task is still in process
  print <<EOS
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
  <a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/view_task.rb" >View your tasks</a>
  </body>
  </html>

EOS
#EOSとかヒアドキュメントの末尾はインデントしたらダメらしい。
end
session.close
rescue => ex
  puts ex.message
  puts ex.backtrace
end
