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



task =[]
user = []

db.transaction(){#ユーザ情報とそれに紐付けられてるタスクのデータを取り出す。
  #ログインしているユーザIDで、終わっていないタスクで、今日やるべきものを抽出する。
  task = db.execute("SELECT * FROM Tasks INNER JOIN Sequence ON Tasks.task_id = Sequence.task_id WHERE Tasks.user_id = ? AND Tasks.done = 0 AND date(Sequence.next_time) = date('now', 'localtime');", session['user'])
  #ユーザ情報の取り出し
  user = db.execute("SELECT * FROM User WHERE user_id = ?;", session['user']).first
}

print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>view_task</title>
</head>
<body>


</script>
<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/update_task.rb" method="post" >
<h1>タスク管理アプリ "自律"</h1>

<h4>Welcome, #{user[1]}! your exp is #{user[2]} points.</h4>
choose one if you finish the task.<br>
EOS

task.each_with_index do |task, i|
  print <<EOS
  ------------------------------------------<br>
	 <p><input type="radio" name="done_task" value=#{task[0]}>#{task[1].chomp()}</p>
   <p>#{task[2]} : since #{task[4].slice(0,11)}</p>

EOS
end


print <<EOS
-------------------------------------------<br>
<p><input type="hidden" name="hidden" value=#{task.length}></p>
	<p><input type="submit" value="submit"></p>
	<p><input type="reset" value="reset"></p>
</form>

<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/add_data.rb" >タスクを追加</a><br>
<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/change_userinfo.rb" >ユーザ名の変更</a>

</body>
</html>
EOS
session.close
rescue => ex
  puts ex.message
  puts ex.backtrace
end
#構造を見やすくするためにあえてCSSは用いておらず、素材本来の出来で勝負します。
