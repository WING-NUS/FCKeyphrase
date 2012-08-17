#!/usr/bin/env ruby
require 'optparse'
require 'ostruct'

def collectStems(dir,ext)
  currDir = Dir.getwd
  Dir.chdir(dir)
  files = Dir.glob("*.#{ext}")
  stems = Array.new
  for file in files do
    startIndex = 0
    endIndex = file.index(".") - 1
    stem = file[startIndex..endIndex]
    stems << stem
  end
  Dir.chdir(currDir)
  return stems
end

relPath = Dir.getwd
Dir.chdir(File.dirname(__FILE__))
$:.push Dir.getwd

#constants
@WEKA_JAR = Dir.getwd + "/../lib/weka/weka.jar"
@RESOURCES = Dir.getwd + "/../data"
@CLASS_INDEX = 6

# set up options / defaults / user customization
options = OpenStruct.new()
options.inputType = Default_Input_Type = "txt"
options.trainDir    = Default_Train_Dir = Dir.getwd + "/../data/train"
options.model    = Default_Model_File = "#{@RESOURCES}/NaiveBayesSimple.model"
  
opts = OptionParser.new do |opts|
  opts.banner = "usage: #{$0} [options]"

  opts.separator ""
  opts.on_tail("-h", "--help", "Show this message") do puts opts; exit end
  opts.on("-t", "--inputType [PROCESSTYPE]", "e.g., #{Default_Input_Type}/pdf") do |o| options.inputType = o end
  opts.on("-d", "--trainDir [TRAINDIR]", "default #{Default_Train_Dir}") do |o| options.trainDir = o end
  opts.on("-m", "--model [MODEL]", "default #{Default_Model_File}") do |o| options.model = o end
end
opts.parse!(ARGV)

if options.trainDir != Default_Train_Dir and !File.exist?(options.trainDir)
  options.trainDir = "#{relPath}/#{options.trainDir}"
end
if !File.exist?(options.trainDir)
  puts "#{options.trainDir} not exist"
  exit
end


stems = collectStems(options.trainDir,"txt.final")

for stem in stems do
  puts "Processing #{stem}"
  if options.inputType == "txt" #pdftotext & pos & stem"
    cmd = "ruby TXTProcessor.rb #{options.trainDir} #{stem}"
  else
    cmd = "ruby PDFProcessor.rb #{options.trainDir} #{stem}"
  end
  system(cmd)
  
  #np filter
  system("ruby NPFilter.rb #{options.trainDir} #{stem}")
  #write feat file
end

# Get name of model
name_of_model = options.model.scan(/[^\/]+$/).first
name_of_model = name_of_model.gsub(/\.[^\.]+$/, "") unless name_of_model[0] == "."

# build dictionary
cmd = "ruby DictionaryBuilder.rb #{options.trainDir} np > #{@RESOURCES}/#{name_of_model}-dictionary.txt"
system(cmd)

# build kp dictionary
cmd = "ruby DictionaryBuilder.rb #{options.trainDir} kwd > #{@RESOURCES}/#{name_of_model}-kp_dictionary.txt"
system(cmd)

for stem in stems do
   system("ruby FeatWriter.rb #{options.trainDir} #{stem} #{@RESOURCES}/#{name_of_model}-dictionary.txt #{@RESOURCES}/#{name_of_model}-kp_dictionary.txt")
end

# write ARFF file
system("ruby ARFFWriter.rb #{options.trainDir} #{@RESOURCES}/#{name_of_model}-train.arff")

# discretize
cmd = "java -cp #{@WEKA_JAR} weka.filters.supervised.attribute.Discretize  -i #{@RESOURCES}/#{name_of_model}-train.arff -o #{@RESOURCES}/#{name_of_model}-train.discretized.arff -c #{@CLASS_INDEX}"
system(cmd)

# build model
cmd = "java -cp #{@WEKA_JAR} weka.classifiers.bayes.NaiveBayesSimple -t #{@RESOURCES}/#{name_of_model}-train.discretized.arff -d #{options.model}"
system(cmd)
