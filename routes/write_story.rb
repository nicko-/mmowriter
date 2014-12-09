module MMOWriter::Routes
  module WriteStory
    def self.registered app     
      app.get '/w/:id' do
        erb :write_story, :locals => {:story => MMOWriter::Models::Story[params[:id]]}, :layout => :global
      end
    end
  end
end