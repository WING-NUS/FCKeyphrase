#!/usr/bin/env ruby

# generate_xml.rb
#
# Generates the Elsevier xml file from the supplied js file
#
# Jesse Gozali
# Jan 2012

$: << File.expand_path(File.dirname(__FILE__))

require 'erb'
require 'rubygems'
require 'bundler/setup'
require 'trollop'
require 'nokogiri'

JQUERY_FILE = File.expand_path(File.dirname(__FILE__)) + "/jquery-1.7.1.min.js"

opts = Trollop::options {
  opt :rhtml, "Path to rhtml file to use", short: "h", required: true, type: String
  opt :js, "Path to js file to use", short: "j", required: true, type: String
  opt :prefs, "Path to YAML file for XML prefs", short: "p", required: true, type: String
  opt :xml, "Path to xml output", short: "o", required: true, type: String
}

# Read XML prefs
prefs = YAML.load_file(opts[:prefs])

# Read jquery
jquery_content = File.open(JQUERY_FILE).readlines.join("")

# Read js file
js_content = File.open(opts[:js]).readlines.join("")

# Render html with binding of js_content above
html = ERB.new(File.open(opts[:rhtml]).readlines.join("")).result(binding)

# Build XML
builder = Nokogiri::XML::Builder.new(encoding: "UTF-8") { |xml|
  xml.Module {
    xml.ModulePrefs(
      title: prefs["title"], 
      author_email: prefs["author_email"]
    ) {
      prefs["require_feature"].each { |feature|
        xml.Require(feature: feature)
      }
    }
    xml.Content(
      type: "html",
      view: "canvas,profile"
    ) {
      xml.cdata(html)
    }
  }
}

# Write to file
File.open(opts[:xml], 'w') { |f|
  f.puts builder.to_xml
}
