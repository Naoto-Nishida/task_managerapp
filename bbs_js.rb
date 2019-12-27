#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'
cgi = CGI.new

print cgi.header("text/html; charset=utf-8")

messages = []
File.open("bbsdata.txt", mode = "rt"){|f|
  messages = f.readlines
}

print <<EOF
<html>
<head>
<meta charset="UTF-8">
<title>form</title>
<head>
<body>
<script type="text/javascript">
function Bbs(){




  this.precheck = function(obj){

    var ret = true;
    var message = obj.message.value;
    var regObj = /<("[^"]*"|'[^']*'|[^'">])*>/;//new RegExp("<("[^"]*"|'[^']*'|[^'">])*>");
    var result = message.match(regObj);

    //console.log("obj");
    //console.log(obj);

    if(obj.name.value.length == 0 || obj.message.value.length == 0){
      alert("名前と本文を入力してください");
      ret = false;
    }

    if(result != null){
      alert("HTMLにタグは使えません");
      ret = false;
    }

    return ret;
  }

}
bbs = new Bbs();

</script>


<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/update.rb" method="post" onsubmit = "return bbs.precheck(this)">
	<p>name： <input type="text" name="name"></p>
	<p>contents： <input type="text" name="message"></p>
	<p><input type="submit" value="Submit!" ></p>
	<p><input type="reset" value="reset" ></p>
</form>

投稿内容: <br>

EOF

(0...messages.length).reverse_each do |i|
	print( messages[i] + "<br>")
end

print <<EOF

</body>
</html>

EOF
