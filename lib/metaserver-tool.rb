module Metaserver
  module Tool
    ROOT = File.expand_path('../', File.dirname(__FILE__))
  end
end

require 'thin'
require 'sinatra'

require "metaserver-tool/version"
require "metaserver-tool/app"
require "metaserver-tool/config"
require "metaserver-tool/server"
require "metaserver-tool/web_app"

$nopid_deletion = false
