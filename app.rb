require 'sinatra/base'

module MMOWriter
  NAME = 'MMOWriter'
  VERSION = '0.0.1'

  class App < Sinatra::Base
    set :root, File.dirname(__FILE__)
    
    get '/' do
      erb :home, :layout => :global
    end
  end
end