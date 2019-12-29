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
  #session記録がない場合、DBのUserに半ば強制的に登録をさせて固有のユーザIDを付加し、後でユーザ名を好みで変えてもらう仕組み。
  db.transaction(){
    db.execute("INSERT INTO User (name, experience_point) VALUES(\"SOMEONE\", 0);")
    session['user'] = db.execute("SELECT user_id FROM User where rowid = last_insert_rowid();").first.first
  }
else
  session['user'] = session['user']
end

task =[]
user = []

db.transaction(){
  task = db.execute("SELECT * FROM Tasks WHERE user_id = ?;", session['user'])
  user = db.execute("SELECT * FROM User WHERE user_id = ? ;", session['user'])
}
if user.length != 1 then
  print("Something went wrong.\n please try again.\n") #もうちょっとエラー処理頑張る
else
  user = user.first
end
print <<EOS
<html>
<head>
<meta charset="UTF-8">
<title>view_task</title>
</head>
<body>


</script>
<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/update_task.rb" method="post" >
<h1>タスク管理</h1>
<h2>#{task}</h2>
<h2>#{user}</h2>
choose one if you finish the task
#{session['user']}
EOS

task.each_with_index do |task, i|
  print <<EOS
	 <p><input type="radio" name="done_task" value=#{task[0]}>#{task[1].chomp()}</p>
   <p>#{task[2]} : since #{task[4]}</p>
EOS
end

#insert into User (name, experience_point) values("Naoto", 1);
#insert into Tasks (subject,detail,howmany, insert_time, user_id) values("Study programming", "just do it, man.", 3, datetime('now', 'localtime'), 1);
#insert into Sequence(task_id,whatkind, next_time, num_th) values(2, 1, "2020-01-01 12:00:00", 1);


print <<EOS
<p><input type="hidden" name="hidden" value=#{task.length}></p>
	<p><input type="submit" value="submit"></p>
	<p><input type="reset" value="reset"></p>
</form>

<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/add_data.rb" >タスクを追加</a>

</body>
</html>
EOS
session.close
rescue => ex
  puts ex.message
  puts ex.backtrace
end
#構造を見やすくするためにあえてCSSは用いておらず、素材本来の出来で勝負します。
