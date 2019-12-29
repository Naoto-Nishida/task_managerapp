#!/usr/bin/env ruby
# encoding: utf-8
print "Pattern: "
pattern = STDIN.gets.chomp
regexp = Regexp.new(pattern, false)
#regexp = Regexp.new(pattern, true)

# gets は実行時に引数として与えられたファイルから
# 一行読み込んだ文字列を返す組み込み関数。
while line = gets
  if regexp =~ line
    print line
  end
end
