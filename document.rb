require 'rubygems'
require 'bundler/setup'
require 'active_record'

# document.rb
#
# This class manages a cached repository of document keyphrases using DOI as key
#
# Jesse Gozali
# Jan 2012

class Document < ActiveRecord::Base
  validates_presence_of :doi, :keyphrases
  validates_uniqueness_of :doi
  serialize :keyphrases
end
