#!/usr/bin/env ruby

inFile = ARGV[0]
outFile = ARGV[1]
f = File.open(inFile)
txt = ""
lines = Array.new
while !f.eof do
  l = f.gets.chomp.strip
  if l != ""
    lines << l
    txt = txt + " " + l
  end
end
f.close

txt = txt.strip
i = 0
newTxt = ""
while i < lines.length do
  if lines[i].downcase.match("([0-9]. )? references?")
    #break
  end
  if lines[i].rindex("-") == lines[i].length - 1 and i < lines.length - 1
    startIndex = lines[i].rindex(" ")
    if startIndex != nil
      line_i = lines[i][0..startIndex].strip
      startIndex = startIndex + 1
    else
      line_i = ""
      startIndex = 0
    end
    endIndex = lines[i].length
    
    firstPart = lines[i][startIndex..endIndex]

    startIndex = 0
    endIndex = lines[i + 1].index(" ")
    if endIndex != nil
      endIndex = endIndex -1
      nextLine = lines[i+1][(endIndex+2)..(lines[i+1].length)]
    else
      endIndex = lines[i+1].length
      nextLine = ""
    end
    secondPart = lines[i+1][startIndex..endIndex]

    word = "#{firstPart}#{secondPart}"
    newWord = word.sub("-", "")
    if txt.downcase.index(word.downcase) == nil #is hyphenated
      newTxt =  newTxt + line_i + " " + newWord + "\n"
    else
      newTxt = newTxt + line_i + " " + "#{word}\n"  
    end
    lines[i+1] = nextLine
  else
    newTxt = newTxt + lines[i] + "\n"
  end
  i = i + 1
end

f = File.open(outFile, "w")
f.write(newTxt)
f.close
