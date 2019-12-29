#!/usr/bin/env ruby
#encoding: utf-8
require 'cgi'
cgi = CGI.new
cookies = cgi.cookies
count = (cookies["mycookie"][0] || 0).to_i + 1
new_cookie= CGI::Cookie.new("name" => "mycookie", "value" => count.to_s)
print cgi.header("type" => "text/plain", "charset" => "utf-8", "cookie" => [new_cookie])
print "count = #{count}"
