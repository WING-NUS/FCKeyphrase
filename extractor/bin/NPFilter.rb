#!/usr/bin/env ruby

BIN_DIR = File.absolute_path(File.dirname(__FILE__)) + "/"
$: << BIN_DIR
require 'NP'

def add_noun_phrase(hash,stem,pos,txt)
  np = hash["#{stem}"]
  if np == nil
    np = NP.new(stem,pos,txt)
    hash["#{stem}"] = np
  end
end

def is_noun_or_adj(pos)
  %w{NN NNS NNP NNPS JJ JJR JJRS}.include?(pos)
end

def is_noun(pos)
  %w{NN NNS NNP NNPS}.include?(pos)
end

def is_qualified(string)
  if string.index(".") != nil or string.index("-lsb-") != nil or string.index("-rsb-") != nil or string.index("+") != nil or string.index("|") != nil or string.index("*") != nil or string.index("=") != nil 
    return false
  end

  if string.length < 3
    return false
  end

  numbers = ["0","1","2","3","4","5","6","7","8","9"]
  i = 0
  while i < string.length
    tmp = string[i..i]
    if !numbers.include?(tmp)
      break
    end
    i = i + 1
  end
  
  if i == string.length
    return false
  end

  tmpArray = string.split(/ /)
  count = 0
  for tmp in tmpArray do
    if tmp.length == 1
      return false
    elsif tmp.length == 2
      count = count + 1
    end
  end
  if count == tmpArray.length and tmpArray.length > 1
    return false
  end
  return true
end

def read_file(file)
  File.open(file).readlines.collect { |line|
    line.chomp.strip
  }.reject { |line|
    line.nil? or line.empty?
  }
end

# Get params
path = ARGV[0]
name = ARGV[1]

# Read files into lines (ignore empty lines)
pos_file  = read_file("#{path}/#{name}.postagged.txt")
stem_file  = read_file("#{path}/#{name}.stemmed.txt")
txt_file  = read_file("#{path}/#{name}.tokenized.txt")

# Collect NP in hash
hash = Hash.new

# Start loop
index = 0
while index < pos_file.length do
  posArray = pos_file[index].chomp.split(/ /)
  stemArray = stem_file[index].chomp.split(/ /)
  txtArray = txt_file[index].chomp.split(/ /)
  i = 0
  pos = ""
  txt = ""
  stem = ""
 
  while i < posArray.length do
    pos =  posArray[i]
    stem = stemArray[i]
    txt =  txtArray[i]

    # Error check
    unless posArray.size == stemArray.size && posArray.size == txtArray.size
      puts "Token count mismatch error on line index: #{index} (pos: #{posArray.size}, stem: #{stemArray.size}, txt: #{txtArray.size})"
      exit(1)
    end

    if is_noun(pos)
      add_noun_phrase(hash,stem,pos,txt)
      j = i - 1
      count = 1
      while j > 0 and count <= 3 do
        pos = posArray[j] + " " + pos
        stem = stemArray[j] + " " + stem
        txt = txtArray[j] + " " + txt
        if count == 1
          if is_noun_or_adj(posArray[j])
            add_noun_phrase(hash,stem,pos,txt)
          end
        elsif count == 2
          if is_noun_or_adj(posArray[j]) and (is_noun_or_adj(posArray[j + 1]) or posArray[j + 1] == "IN")
            add_noun_phrase(hash,stem,pos,txt)
          end
        elsif count == 3
          if (is_noun_or_adj(posArray[j]) and is_noun(posArray[j + 1]) and posArray[j+2] == "IN") or (is_noun(posArray[j]) and posArray[j+1] == "IN" and is_noun_or_adj(posArray[j+2]))
            add_noun_phrase(hash,stem,pos, txt)
          end
        end
        j = j - 1
        count = count + 1
      end
    end #end if i
    i = i + 1
  end
  index = index + 1
end

npFile = File.open("#{path}/#{name}.np", "w")
keys = hash.keys.sort!
for key in keys do
  np = hash["#{key}"]
  if is_qualified(key)
    npFile.write("#{np.stem} --- #{np.pos} --- #{np.txt}\n")
  end
end
npFile.close
