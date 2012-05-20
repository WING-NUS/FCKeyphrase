#!/usr/bin/env ruby

# keyphrase.rb
#
# A wrapper for the KPExtractor.rb class
# This class manages the file management and extracts the results
# 
# Jesse Gozali
# Jan 2012

class Keyphrase

  KPEXTRACTOR_CMD = "ruby path_to_extractor.rb"
  TMP_DIR = "/tmp/FCKeyphrase_"
  NON_KEYPHRASES = %w{results}

  def self.extract(text)
    tmp = Time.now.to_i.to_s

    # Write text to file
    File.open(TMP_DIR + tmp + ".txt", 'w') { |f| f.puts text }

    # Call cmd line and read results
    lines = []
    IO.popen(KPEXTRACTOR_CMD + " " + TMP_DIR + tmp + ".txt") { |io|
      lines = io.readlines
    }

    # Extract keyphrases
    keyphrases = []
    lines.each { |line|
      next unless line.match(/^<txt>/)
      keyphrase = line.scan(/^<txt>(.*)<\/txt>$/).first.first
      keyphrases << keyphrase unless NON_KEYPHRASES.include? keyphrase.downcase
    }

    return keyphrases
  end
end
