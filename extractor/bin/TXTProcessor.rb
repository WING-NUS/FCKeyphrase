#!/usr/bin/env ruby
#
# This code processes the given txt.final file at the given path (ARGV[0]) of the
# given name (ARGV[1]). i.e. The file is at ARGV[0]/ARGV[1].txt.final
#
# to produce four files:
# - .txt (hyphens removed)
# - .tokenized.txt (tokenized)
# - .postagged.txt (POS tagging)
# - .stemmed.txt (stemming)
#
# Via three temp files (removed each time)
# - .tmp.eos (sentence segmented)
# - .tmp.tokenized (tokenized)
# - .tmp.postagged (POS tagging)
#
# Documentation and code clean-up
# by Jesse Gozali
#
# June 2, 2012

BIN_DIR = File.absolute_path(File.dirname(__FILE__)) + "/"
LIB_DIR = BIN_DIR + "../lib/"
MXTAG_DIR = LIB_DIR + "mxtag"
LAPOSTAG_BIN = LIB_DIR + "lapos-0.1.1/lapos"
LAPOSTAG_MODEL = LIB_DIR + "lapos-0.1.1/model_wsj02-21"
HYPHENFILTER_BIN = BIN_DIR + "HyphenFilter.rb"
PORTER_BIN = BIN_DIR + "porter.pl"

# Process args
path = ARGV[0]
name = ARGV[1]

# Remove hyphen - references
system("#{HYPHENFILTER_BIN} #{path}/#{name}.txt.final #{path}/#{name}.txt")

# Segment text into sentences
system("java -mx30m -cp #{MXTAG_DIR}/mxpost.jar eos.TestEOS #{MXTAG_DIR}/eos.project < #{path}/#{name}.txt > #{path}/#{name}.tmp.eos 2>/dev/null")

# Tokenizer
system("java -cp #{BIN_DIR} Tokenizer #{path}/#{name}.tmp.eos #{path}/#{name}.tmp.tokenized")
       
# Look-ahead POS tagging
system("#{LAPOSTAG_BIN} -m #{LAPOSTAG_MODEL} < #{path}/#{name}.tmp.tokenized > #{path}/#{name}.tmp.postagged 2>/dev/null")

# Split the postagged file into 2 files: txt and pos
f = File.open("#{path}/#{name}.tmp.postagged")
txtFile = File.open("#{path}/#{name}.tokenized.txt", "w")
posFile = File.open("#{path}/#{name}.postagged.txt", "w")
while !f.eof do
  l = f.gets.chomp.strip
  wordArray = l.split(/ /)
  txt = ""
  pos = ""
  for word in wordArray do
    # Bug fix for when txt has "/"
    # tmp = word.split(/\//)
    # txt = txt + tmp[0] + " "
    # pos = pos + tmp[1] + " "
    txt = txt + word.scan(/^(.+)\/[^\/]+$/).first.first + " "
    pos = pos + word.scan(/\/([^\/]+)$/).first.first + " "
  end
  txtFile.write(txt.strip + "\n")
  posFile.write(pos.strip + "\n")
end
f.close
txtFile.close
posFile.close

# Stemming
system(PORTER_BIN + " #{path}/#{name}.tokenized.txt > #{path}/#{name}.stemmed.txt")

# Remove tmp files
File.unlink("#{path}/#{name}.tmp.eos")
File.unlink("#{path}/#{name}.tmp.tokenized")
File.unlink("#{path}/#{name}.tmp.postagged")
