#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'
require 'digest/md5'

relPath = Dir.getwd + "/"
Dir.chdir(File.dirname(__FILE__))
$:.push Dir.getwd
require 'Instance'

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
def getInstance(stem, inst_array)
  i = 0
  index = -1
  while i < 100 and i < inst_array.length do
    if inst_array[i].stem.index(stem) != nil
	index = i
        stem = inst_array[i].stem
    end 
    i = i + 1
  end
  return inst_array[index]
end
def isQualified (str, array)
  for a in array do
    if a.index(str) != nil
      return false
    end
  end
  return true
end


@WEKA_JAR = Dir.getwd + "/../lib/weka/weka.jar"
@TEST_DIR = "/tmp"
@RESOURCES = Dir.getwd + "/../data"
@CLASS_INDEX = 6

options = OpenStruct.new()
options.numKPs  = Default_Num_Keyphrases = 15 
options.output = Default_Output = "STDOUT"
options.addInfo = Default_Additional_Info = "no"
options.model    = Default_Model_File = "#{@RESOURCES}/NaiveBayesSimple.model"

opts = OptionParser.new do |opts|
  opts.banner = "usage: #{$0} [options] txt_file"

  opts.separator ""
  opts.on_tail("-h", "--help", "Show this message") do puts opts; exit end
  opts.on("-n", "--numKPs [NUMKPS]", "default #{Default_Num_Keyphrases}") do |o| options.numKPs = o end
  opts.on("-o", "--output [OUTPUT]", "default #{Default_Output}") do |o| options.output = o end
  opts.on("-a", "--addInfo [ADDINFO]", "yes/no default no") do |o| options.addInfo = o end
  opts.on("-m", "--model [MODEL]", "default #{Default_Model_File}") do |o| options.model = o end
end
opts.parse!(ARGV)

filename = ARGV[0]
if !File.exist?(filename)
  filename = relPath + filename
end
if !File.exist?(filename)
  puts "Input file #{ARGV[0]} does not exist"
  exit
end

# Get name of model
name_of_model = options.model.scan(/[^\/]+$/).first
name_of_model = name_of_model.gsub(/\.[^\.]+$/, "") unless name_of_model[0] == "."

stem = Time.now.to_i
cmd  = "cp #{filename} #{@TEST_DIR}/#{stem}.txt.final"
system(cmd)

#process
cmd = "ruby TXTProcessor.rb #{@TEST_DIR} #{stem}"
system(cmd)

#np filter
cmd = "ruby NPFilter.rb #{@TEST_DIR} #{stem}"
system(cmd)

#write feat file
cmd = "ruby FeatWriter.rb #{@TEST_DIR} #{stem} #{@RESOURCES}/#{name_of_model}-dictionary.txt #{@RESOURCES}/#{name_of_model}-kp_dictionary.txt"
system(cmd)
#write arff file
cmd = "ruby ARFFWriter.rb #{@TEST_DIR}/#{stem}.feat #{@TEST_DIR}/#{stem}.arff"
system(cmd)

#discretized
cmd = "java -cp #{@WEKA_JAR} weka.filters.supervised.attribute.Discretize -b -i #{@RESOURCES}/train.arff -r #{@TEST_DIR}/#{stem}.arff -s #{@TEST_DIR}/#{stem}.discretized.arff -c #{@CLASS_INDEX} > /dev/null"
system(cmd)

cmd = "java -cp #{@WEKA_JAR}  weka.classifiers.bayes.NaiveBayesSimple -l #{options.model} -T #{@TEST_DIR}/#{stem}.discretized.arff -p 0 -distribution > #{@TEST_DIR}/#{stem}.output"
system(cmd)

f = File.open("#{@TEST_DIR}/#{stem}.output")
index = 0
probArray = Array.new
while !f.eof do
  l = f.gets.chomp.strip
  if l != ""
    index = index + 1
  end
  if index > 2 and l != ""
    first_array  = l.split(/ /)
    distribution = "#{first_array[first_array.length - 1]}"
    sec_array = distribution.split(/,/)
    prob = sec_array[0]
    if prob.index("*") == 0
      prob = prob[1..prob.length]
    end
    probArray << prob
  end
end
f.close


#read feat file
f = File.open("#{@TEST_DIR}/#{stem}.feat")
index = 0
inst_array = Array.new
while !f.eof do
  l = f.gets.chomp.strip
  featHash = getFeatures(l)
  txt = featHash["txt"]
  stem = featHash["stem"]
  pos  = featHash["pos"]
  tf_idf = featHash["tf_idf"]
  fo = featHash["fo"]
  tf_sub = featHash["tf_sub"]
  len = featHash["len"]
  kp_freq = featHash["kp_freq"]
  prob = probArray[index]
  inst = Instance.new(txt,stem,pos,tf_idf,fo,tf_sub,len,kp_freq, prob)
  inst_array << inst
  index = index + 1
end
f.close

#sort by tf_idf desc
i = 0
while i < inst_array.length - 1 do
  j = i + 1
  while j < inst_array.length do
    if inst_array[i].tf_idf < inst_array[j].tf_idf
      tmp = inst_array[i]
      inst_array[i] = inst_array[j]
      inst_array[j] = tmp
    end
    j = j + 1
  end
  i = i + 1
end

#sort by fo asc

i = 0
while i < inst_array.length - 1 do
  j = i + 1
  while j < inst_array.length do
    if inst_array[i].fo > inst_array[j].fo
      tmp = inst_array[i]
      inst_array[i] = inst_array[j]
      inst_array[j] = tmp
    end
    j = j + 1
  end
  i = i + 1
end
#sort inst by prob desc
i = 0
while i < inst_array.length - 1 do
  j = i + 1
  while j < inst_array.length do
    if inst_array[i].prob < inst_array[j].prob
      tmp = inst_array[i]
      inst_array[i] = inst_array[j]
      inst_array[j] = tmp
    end
    j = j + 1
  end
  i = i + 1
end

kp_array = Array.new
result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<algorithm name=\"WINGNUS_KP\" version=\"100806\">";
count = 0
index = 0

while index < inst_array.length do
  stem = inst_array[index].stem
  inst = getInstance(stem,inst_array)
  if isQualified(inst.stem, kp_array)
    kp_array << inst.stem
    result = result + "\n<keyphrase>\n<txt>#{inst.txt}<\/txt>"
    if options.addInfo == "yes"
	result = result + "\n<stem>#{inst.stem}<\/stem>"
    end
    result = result +"\n<\/keyphrase>"
    count = count + 1
    if count == options.numKPs.to_i
	break
    end
  end
  index = index + 1
end
result = result + "\n<\/algorithm>"
if options.output != "STDOUT"
  f = File.open("#{options.output}","w")  
  f.write("#{result}\n")
  f.close
else
    puts "#{result}"
end
