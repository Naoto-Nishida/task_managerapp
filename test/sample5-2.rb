#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'
cgi= CGI.new
session = CGI::Session.new(cgi)
session['count'] = (session['count'] || 0).to_i + 1
print cgi.header("text/plain; charset=utf-8")
print "count = #{session['count']}"
session.close
