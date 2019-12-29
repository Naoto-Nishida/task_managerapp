#!/usr/bin/env ruby
# encoding: utf-8
#
# このCGIを実行する前に、プリントのRubyスクリプトから
# INSERT文を使う例を実行しておく。
#
require "cgi"
require "sqlite3"

cgi = CGI.new
print cgi.header("text/html; charset=UTF-8")

begin
  number = cgi['number']
  rows = ''  # 検索結果を入れる変数rowsを初期化する
  if number.empty?
    raise "学籍番号を入力してください"
  end
  db = SQLite3::Database.new("test.db")
  db.transaction() {
    rows = db.execute("SELECT * FROM mytbl WHERE id like ?;", number)
  }
  db.close

  print <<-EOB
  <html>
    <head>
      <meta charset="UTF-8" />
    </head>
    <body>
      <h1>検索結果</h1>
  EOB
  if rows.size > 0
    rows.each {|row|
      puts "<div>学籍番号 = #{row[0]}, 氏名 = #{row[1]}</div>"
    }
  else
    puts "該当する学籍番号は見つかりませんでした。"
  end
  print <<-EOB
    </body>
  </html>
  EOB
rescue => ex
  print <<-EOB
  <html>
    <head>
      <meta charset="UTF-8" />
    </head>
    <body>
      <h1>#{ex.message}</h1>
      <pre>
#{CGI.escapeHTML(ex.backtrace.join("\n"))}
      </pre>
    </body>
  </html>
  EOB
end
