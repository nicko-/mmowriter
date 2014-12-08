require 'sinatra/base'

module MMOWriter
  NAME = 'MMOWriter'
  VERSION = '0.0.1'

  class App < Sinatra::Base
    set :root, File.direname(__FILE__)
  end
end