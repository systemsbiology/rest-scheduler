begin
  # Try to require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fall back on doing an unlocked resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

Bundler.require

require 'rufus/scheduler'
require 'xmlsimple'
require 'active_record'
require 'rest_client'
require 'sinatra/base'
require 'sinatra/url_for'
