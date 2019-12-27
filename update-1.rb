#!/usr/bin/env ruby
# encoding: UTF-8
require 'cgi'
cgi = CGI.new

print cgi.header("text/html; charset=utf-8")
name  = cgi["name"]
message  = cgi["message"]

time = Time.now.to_s

print <<EOF
<html>
<head>
<meta charset="UTF-8">
<title>update</title>
<head>
<body>
thanks.<br>
<br>
your comment is :
<p>#{name}: #{message}</p>
<br>
<a href= "http://cgi.u.tsukuba.ac.jp/~s1811433/local_only/wp/bbs_js.rb" >もっと掲示板に書き込む</a>


</body>
</html>

EOF

data = open("bbsdata.txt", "a:UTF-8")
data.write(name + ": " + message + "---" + time + "\n")
data.close
