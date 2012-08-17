#!/usr/bin/env ruby

Dir.chdir(File.dirname(__FILE__))
$:.push Dir.getwd

@NUM_DOCS = 244

path = ARGV[0]
name = ARGV[1]
dictionary = ARGV[2]
kp_dictionary = ARGV[3]

#read txt file into string
def readFileToString(filePath)
  result = ""
  f = File.open(filePath)
  while !f.eof do
    l = f.gets.chomp.strip
    result = result + l + " "
  end
  f.close
  return result.strip
end

#key : string, value : freq
def readFileToHash(filePath)
  result = Hash.new
  f = File.open(filePath)
  while !f.eof do
    l = f.gets.chomp.strip.split(/---/)
    key = l[0].strip
    value = l[1].strip.to_i
    result["#{key}"] = value
  end
  return result
end

def readFileToArray(filePath)
  result = Array.new
  if File.exist?(filePath)
    f = File.open(filePath)
    while !f.eof do
      l = f.gets.chomp.strip
      result << l
    end
  end
  return result
end

def getFirstOccur(str, subStr)
  index = str.index(subStr)
  if index > 0
    index = index - 1
    prefix = str[0..index].strip
    return (prefix.split(/ /).length * 1.0)/str.split(/ /).length
  else
    return 0
  end

end

def getFreq(str, subStr)
  index = str.index(subStr)
  count = 0
  while index != nil do
    count = count + 1
    offset = index + subStr.length
    index = str.index(subStr,offset)
  end
  return count
end

def getSubFreq(hash,str)
  freq = hash["#{str}"]
  tmp = str.split(/ /)
  if tmp.length == 2
    a = hash.has_key?(tmp[0]) ? hash["#{tmp[0]}"] : 0
    b = hash.has_key?(tmp[1]) ? hash["#{tmp[1]}"] : 0
    freq = freq + a + b
  elsif tmp.length == 3
    a = hash.has_key?(tmp[0]) ? hash["#{tmp[0]}"] : 0
    b = hash.has_key?(tmp[1]) ? hash["#{tmp[1]}"] : 0
    c = hash.has_key?(tmp[2]) ? hash["#{tmp[2]}"] : 0
    ab = hash.has_key?("#{tmp[0]}#{tmp[1]}") ? hash["#{tmp[0]}#{tmp[1]}"] : 0
    bc = hash.has_key?("#{tmp[1]}#{tmp[2]}") ? hash["#{tmp[1]}#{tmp[2]}"] : 0
    freq = freq + a + b + c + ab + bc
  elsif tmp.length == 4 #max length
    a = hash.has_key?(tmp[0]) ? hash["#{tmp[0]}"] : 0
    b = hash.has_key?(tmp[1]) ? hash["#{tmp[1]}"] : 0
    c = hash.has_key?(tmp[2]) ? hash["#{tmp[2]}"] : 0
    d = hash.has_key?(tmp[3]) ? hash["#{tmp[3]}"] : 0
    ab = hash.has_key?("#{tmp[0]}#{tmp[1]}") ? hash["#{tmp[0]}#{tmp[1]}"] : 0
    bc = hash.has_key?("#{tmp[1]}#{tmp[2]}") ? hash["#{tmp[1]}#{tmp[2]}"] : 0
    cd = hash.has_key?("#{tmp[2]}#{tmp[3]}") ? hash["#{tmp[2]}#{tmp[3]}"] : 0
    abc = hash.has_key?("#{tmp[0]}#{tmp[1]}#{tmp[2]}") ? hash["#{tmp[0]}#{tmp[1]}#{tmp[2]}"] : 0
    bcd = hash.has_key?("#{tmp[1]}#{tmp[2]}#{tmp[3]}") ? hash["#{tmp[1]}#{tmp[2]}#{tmp[3]}"] : 0
    freq = freq + a + b + c + ab + bc + cd + abc + bcd
  end
  return freq
end



##################
#main script
##################
txtContent = readFileToString("#{path}/#{name}.stemmed.txt")
sumFreq = 0
freqHash = Hash.new
posHash = Hash.new
txtHash = Hash.new
#get frequency
f = File.open("#{path}/#{name}.np")
while !f.eof do
  l = f.gets.chomp.strip.split(/---/)
  stem = l[0].strip
  pos  = l[1].strip
  txt  = l[2].strip
  freq = getFreq(txt, stem)
  freqHash["#{stem}"] = freq
  posHash["#{stem}"]  = pos
  txtHash["#{stem}"] = txt
  sumFreq = sumFreq + freq
end
f.close

#get substring frequency
subHash = Hash.new
keys = freqHash.keys
for key in keys do
  subHash["#{key}"] = getSubFreq(freqHash,key)
end

#get dictionary
dfHash  = readFileToHash("#{dictionary}")
#get keyphrase dictionary
kpHash  = readFileToHash("#{kp_dictionary}")
#get kwds if exist
kwd = readFileToArray("#{path}/#{name}.kwd")
#write feat file
f = File.open("#{path}/#{name}.feat", "w")
for key in keys do
  tf      = freqHash["#{key}"]*1.0/sumFreq
  df      = dfHash.has_key?(key) ? dfHash["#{key}"] : 0
  idf     = Math.log(@NUM_DOCS*1.0/(1 + df.to_i))
  tf_idf  = tf*idf
  tf_sub  = subHash["#{key}"]
  len     = key.split(/ /).length
  fo      = getFirstOccur(txtContent,key)
  pos     = posHash["#{key}"]
  txt     = txtHash["#{key}"]
  kp_freq = kpHash.has_key?(key) ? kpHash["#{key}"] : 0
  classname = "?"
  if kwd.length > 0
    if kwd.include?(key)
      classname = "yes"
    else
      classname = "no"
    end
  end
  featStr = "txt=#{txt}, stem=#{key}, pos=#{pos}, tf_idf=#{tf_idf}, fo=#{fo}, tf_sub=#{tf_sub}, len=#{len}, kp_freq=#{kp_freq}, classname=#{classname}"
  f.write(featStr + "\n")
end
f.close
