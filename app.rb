require 'sinatra/base'
require 'sequel'
require 'securerandom'
require 'json'

module MMOWriter
  NAME = 'MMOWriter'
  VERSION = '0.0.1'
  VOTE_TIMEOUT = 30
    
  DB = Sequel.connect 'sqlite://mmowriter.db'
end

# relative requires here
require_relative 'models/story'
require_relative 'models/action'
require_relative 'models/vote'

require_relative 'routes/write_story'

module MMOWriter
  class App < Sinatra::Base

    set :root, File.dirname(__FILE__)
    
    before '/*' do # Before everything
      # If user does not have a UUID, give them one
      response.set_cookie('u', SecureRandom.uuid) if request.cookies['u'].nil?
    end
    
    get '/' do
      erb :write_story, :layout => :global, :locals => {:story => Story.where(:completed => false).last}
    end
    
    register Routes::WriteStory
  end
end