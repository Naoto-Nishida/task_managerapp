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
    var subject = obj.subject.value;
    var detail = obj.detail.value;
    var howmany = obj.howmany.value;
    var regObj_htmltag = /<("[^"]*"|'[^']*'|[^'">])*>/;//new RegExp("<("[^"]*"|'[^']*'|[^'">])*>");
    var regObj_number = /.*[^0-9]+/;
    var result_subject = subject.match(regObj_htmltag);
    var result_detail = detail.match(regObj_htmltag);
    var result_howmany = howmany.match(regObj_number);

    //console.log("obj");
    //console.log(obj);

    if(subject.length == 0 || detail.length == 0 || howmany.length == 0){
      alert("input the name of the task, the detail, and the times of reccursion");
      ret = false;
    }

    if(subject.length > 30 || detail.length >140 ){
      alert("characters must be in the specified length!");
      ret = false;
    }

    if(result_howmany != null){
      alert("reccursion time must be an integer");
      ret = false;
    }

    if(result_subject != null || result_detail != null){
      alert("HTMLにタグは使えません");
      ret = false;
    }

    if(perseInt(howmany) < 0 ){
      alert("繰り返しに負の数は使えません");
      ret = false;
    }

    return ret;
  }

}
task = new Task();

</script>


<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/add_confirm.rb" method="post" onsubmit = "return task.precheck(this)">
	<p>subject(less than 30 characters)： <input type="text" name="subject"></p>
  <p>detail(less than 140 characters)： <input type="text" name="detail"></p>
  <p>how many times do you want to continue this habit?： <input type="text" name="howmany"></p>
  <p>Habitual cycle： <input type="radio" name="whatkind" checked = "checked" value = "0">everyday <input type="radio" name="whatkind" value = "1">everyweek <input type="radio" name="whatkind" value = "2">everymonth <input type="radio" name="whatkind" value = "3">ebbinghaus forgetting curve</p>
	<p><input type="submit" value="Submit!" ></p>
	<p><input type="reset" value="reset" ></p>
</form>
<br>
<p6>when you choose ebbinghaus forgetting curve option, there is no reccursion time of more than 7.</p6>
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
