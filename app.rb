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
require_relative 'routes/archive'

Thread.abort_on_exception = true

module MMOWriter
  class App < Sinatra::Base
    attr_accessor :worker_started
    set :root, File.dirname(__FILE__)
    
    def start_background_thread
      $mmowriter_worker_started = true
      
      # Background job thread
      Thread.new do
        loop do
          target = Time.now.to_i + 1
          while Time.now.to_i < target do sleep 0.05 end # sync with system clock

          Story.where(:completed => false).each do |story|
             # execute most popular action and clear if timeout has been reached
            story.execute_most_popular_action_and_clear if (Time.now.to_i - story.date_created) % MMOWriter::VOTE_TIMEOUT == 0
          end
        end
      end
    end
    
    before '/*' do # Before everything
      # If user does not have a UUID, give them one
      response.set_cookie('u', SecureRandom.uuid) if request.cookies['u'].nil?
      start_background_thread if !$mmowriter_worker_started
    end
    
    get '/' do
      erb :write_story, :layout => :global, :locals => {:story => Story.where(:completed => false).last}
    end
    
    register Routes::WriteStory
    register Routes::Archive
  end
end