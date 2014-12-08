require 'sinatra/base'

module MMOW
  class App < Sinatra::Base
    set :root, File.direname(__FILE__)
  end
end