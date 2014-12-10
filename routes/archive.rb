module MMOWriter::Routes
  module Archive
    def self.registered app
      app.get '/a/' do
        erb :archive_index, :layout => :global
      end
    end
  end
end