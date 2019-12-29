#!/usr/bin/env ruby
# encoding: UTF-8
require 'sqlite3'
require 'cgi'
require 'cgi/session'
cgi = CGI.new
session = CGI::Session.new(cgi)


print cgi.header("text/html; charset=utf-8")

begin

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

print <<EOF
<html>
<head>
<meta charset="UTF-8">
<title>form</title>
<head>
<body>
<script type="text/javascript">
function Task(){

  this.precheck = function(obj){

    var ret = true;
    var username = obj.username.value;
    var regObj_htmltag = /<("[^"]*"|'[^']*'|[^'">])*>/;//new RegExp("<("[^"]*"|'[^']*'|[^'">])*>");
    var result_username = username.match(regObj_htmltag);


    //console.log("obj");
    //console.log(obj);

    if(obj.username.value.length == 0){
      alert("input the name");
      ret = false;
    }

    if(obj.username.value.length > 30){
      alert("characters must be in the specified length!");
      ret = false;
    }

    if(result_username != null ){
      alert("HTMLにタグは使えません");
      ret = false;
    }

    return ret;
  }

}
task = new Task();

</script>


<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/update_userinfo.rb" method="post" onsubmit = "return task.precheck(this)">
	<p>username(less than 30 characters)： <input type="text" name="username"></p>
  <p><input type="submit" value="Submit!" ></p>
	<p><input type="reset" value="reset" ></p>
</form>
<br>
EOF
#when input numbers, radio input should be used. but this time we used text input for the validation problem.


print <<EOF

</body>
</html>

EOF
session.close
rescue => ex
  puts ex.message
  puts ex.backtrace
end
