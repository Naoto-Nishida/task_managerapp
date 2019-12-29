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
<form action="http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/update.rb" method="post" >
	<p>name： <input type="text" name="name"></p>
	<p>contents： <input type="text" name="message"></p>
	<p><input type="submit" value="submit"></p>
	<p><input type="reset" value="reset"></p>
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
