#!/usr/bin/env /usr/local/rvm/rubies/ruby-1.9.2-p180/bin/ruby

$: << File.expand_path(File.dirname(__FILE__))

ENV['GEM_HOME'] = "/usr/local/rvm/gems/ruby-1.9.2-p180"

require 'cgi'
require 'uri'
require 'rubygems'
require 'bundler/setup'
require 'json'
require 'escape'
require '../document_controller.rb'
require '../keyphrase.rb'

# Process cgi
cgi = CGI.new("html4")

# Check parameter
if cgi["doi"].nil? or cgi["doi"].strip.empty? then
  # TODO: Also white list domains here (ENV['HTTP_HOST'], etc)
  cgi.out("status" => "BAD_REQUEST") { "400 Bad Request" }
  exit
end

# Be paranoid
doi = Escape.shell_single_word(CGI.unescape(cgi["doi"]))

# Establish connection
doc_controller = DocumentController.new

# Check cache
doc = doc_controller.search(doi)

# If not cached and no text given, return 200 with empty string
unless doc or (not cgi["text"].nil? and not cgi["text"].strip.empty?)
  cgi.out("text/plain") { "" }
  exit
end

# If Not cached, but text is available, find keyphrases
unless doc
  # Strip tags and do other heuristics
  text = cgi["text"].gsub(/<[^>]+>/, " ")
  text = text.gsub(/^.+<originalText>/, "").gsub(/<\/originalText>.+$/, "")
  text = text.gsub(/<[^>]+>/, " ")
  loc = text.index("Abstract ")
  text = text[loc..-1] if loc
  loc = text.rindex("References")
  text = text[0..(loc-1)] if loc
  text = text.gsub(/Keywords/, "")

  # Be paranoid
  text = Escape.shell_single_word(CGI.unescape(text))

  keyphrases = Keyphrase.extract(text)

  # Create new doc
  doc = doc_controller.create(doi: doi, keyphrases: keyphrases)
end

# Send keyphrases
if doc
  cgi.out("text/plain") { doc.keyphrases.join(",") }
else
  cgi.out("status" => "BAD_REQUEST") { "400 Bad Request" }
end
