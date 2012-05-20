#!/usr/bin/env ruby

$: << File.expand_path(File.dirname(__FILE__))

require 'yaml'
require 'rubygems'
require 'bundler/setup'
require 'active_record'
require 'document.rb'

class DocumentController
  DATABASE_FILE = File.expand_path(File.dirname(__FILE__)) + "/database.yml"

  def initialize
    connect_to_database
  end

  def search(doi)
    Document.find_by_doi(doi)
  end

  def create(params)
    doc = Document.new(params)
    if doc.save
      doc
    else
      false
    end
  end

  def update(doi, params)
    document = Document.find_by_doi(doi)
    document ? document.update_attributes(params) : false
  end

  def destroy(doi)
    document = Document.find_by_doi(doi)
    document ? document.destroy : false
  end

  private
  def connect_to_database
    # Read database info from file
    db_info = load_database_file

    # Connect to DB
    ActiveRecord::Base.establish_connection(
      adapter:  "mysql2",
      encoding: "utf8",
      reconnect: true,
      host:     db_info["host"],
      database: db_info["database"],
      username: db_info["username"],
      password: db_info["password"],
      socket:   db_info["socket"]
    )
  end

  def load_database_file
    YAML.load_file(DATABASE_FILE)      
  end
end
