#!/usr/bin/env ruby

#tf_idf, tf_sub, fo, len, kp_freq
def getFeatures(str)
  hash = Hash.new
  tmpArray  = str.split(/,/)
  for tmp in tmpArray do
    subArray = tmp.split(/=/)
    key = subArray[0].strip
    value = subArray[1].strip
    hash["#{key}"] = value
  end
  return hash
end
path = ARGV[0]
arffFile = ARGV[1]

g = File.open(arffFile,"w")
g.write("\n")
g.write("@RELATION kp\n")
g.write("@ATTRIBUTE tf_idf NUMERIC\n")
g.write("@ATTRIBUTE fo NUMERIC\n")
g.write("@ATTRIBUTE tf_sub NUMERIC\n")
g.write("@ATTRIBUTE len NUMERIC\n")
g.write("@ATTRIBUTE kp_freq NUMERIC\n")
g.write("@ATTRIBUTE class {yes, no}\n")
g.write("@DATA\n")
featFiles = Array.new
if File.directory?(path)
  currDir = Dir.getwd
  Dir.chdir(path)
  featFiles = Dir.glob("*.feat")
  Dir.chdir(currDir)
  path = path + "/"
else
  featFiles << path
  path = ""
end
for feat in featFiles do
 
  f = File.open("#{path}#{feat}")
  while !f.eof do
    l = f.gets.chomp.strip
    featHash = getFeatures(l)
    tf_idf = featHash["tf_idf"]
    fo = featHash["fo"]
    tf_sub = featHash["tf_sub"]
    len = featHash["len"]
    kp_freq = featHash["kp_freq"]
    classname = featHash["classname"]
    g.write("#{tf_idf},#{fo},#{tf_sub},#{len},#{kp_freq},#{classname}\n")
  end
  f.close
end
g.close

