require 'sinatra/base'
require 'sequel'
require 'securerandom'

module MMOWriter
  NAME = 'MMOWriter'
  VERSION = '0.0.1'
  
  DB = Sequel.connect 'sqlite://mmowriter.db'
end

# relative requires here

module MMOWriter
  class App < Sinatra::Base
    set :root, File.dirname(__FILE__)
    
    before '/*' do # Before everything
      # If user does not have a UUID, give them one
      response.set_cookie('u', SecureRandom.uuid) if request.cookies['u'].nil?
    end
    
    get '/' do
      erb :home, :layout => :global
    end
  end
end