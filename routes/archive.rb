module MMOWriter::Routes
  module Archive
    def self.registered app
      app.get '/a/' do
        erb :archive_index, :layout => :global
      end
      
      app.get '/a/:id' do
        raise 'no such story with that id' if MMOWriter::Story[params[:id]].nil?
        erb :archive_view, :locals => {:story => MMOWriter::Story[params[:id]]}, :layout => :global
      end
    end
  end
end