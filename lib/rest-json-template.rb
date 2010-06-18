
require File.expand_path('../rest-json-template/builder', __FILE__)

if defined?(Rails)
  require 'rest-json-template/rails'
end

if defined?(Sinatra)
  require 'rest-json-template/sinatra'
end

