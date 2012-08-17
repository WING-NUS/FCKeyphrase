#!/usr/bin/env ruby

def readFile(name)
  result = Array.new
  f = File.open(name)
  while !f.eof do
    l = f.gets.chomp.strip
    tmpArray = l.split(/---/)
    result << tmpArray[0].strip
  end
  return result
end



hash = Hash.new
npFiles = Dir.glob("#{ARGV[0]}/*.#{ARGV[1]}")
for npFile in npFiles do
  npArray = readFile(npFile)
  for np in npArray do
    if hash["#{np}"] != nil
      hash["#{np}"] = hash["#{np}"] + 1
    else
      hash["#{np}"] = 1
    end
  end
end

keys = hash.keys
for key in keys do
  freq = hash["#{key}"]
  puts "#{key} --- #{freq}"
end
