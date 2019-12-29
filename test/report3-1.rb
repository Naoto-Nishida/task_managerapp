#!/usr/bin/env ruby
# encoding: UTF-8

hashdayo = Hash.new(0)

io = open("sample3-1.txt", "r:UTF-8")
while alphabet = io.gets
  alphabet = alphabet.chomp
  hashdayo[alphabet] += 1
end

io.close

hashdayo.sort.to_a.each do |idx|
  printf("%s = %d \n", idx[0], idx[1])
end
