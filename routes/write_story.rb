module MMOWriter::Routes
  module WriteStory
    def self.registered app
      app.before '/w/:id*' do
        raise 'no such story with that id' if MMOWriter::Story[params[:id]].nil?
      end
    
      app.get '/w/:id' do
        redirect to("/a/#{params[:id]}") if MMOWriter::Story[params[:id]].completed == 1
        erb :write_story, :locals => {:story => MMOWriter::Story[params[:id]]}, :layout => :global
      end
      
      app.get '/w/:id/ajax_on_clock' do
        content_type :json
        cache_control :no_cache, :no_store
      
        story = MMOWriter::Story[params[:id]]
        html_buttons = ''
        
        if story.votes.length < 1
          html_buttons = 'no votes yet'
        else
          votes = {}
          story.votes.each do |vote|
            vote_hash = {:type => vote.action_type, :metadata => vote.action_metadata}
            votes[vote_hash] = 0 if votes[vote_hash].nil?
            votes[vote_hash] += 1
          end
          popular_votes = votes.sort_by {|_, v| v}
          popular_votes = popular_votes[-5 .. -1] if popular_votes.length > 5
          
          
          popular_votes.reverse.each do |vote|
            text = vote[0][:metadata]
            color_string = ''
            
            case vote[0][:type]
            when 'special_start_char', 'special_end_char'
              color_string = '_green'
            when 'paragraph'
              text = 'new paragraph'
              color_string = '_green'
            when 'story_end'
              text = 'story end'
              color_string = '_red'
            end
            html_buttons += "<button type=\"button\" class=\"user_input_button#{color_string}\" onclick=\"postVote('#{vote[0][:type]}', '#{vote[0][:metadata]}')\"> #{vote[1]} vote#{'s' if vote[1] != 1} | " + Rack::Utils.escape_html(text) + "</button> "
          end
        end
        
        JSON.generate({'h' => html_buttons, 'c' => (MMOWriter::VOTE_TIMEOUT - ((Time.now.to_i - story.date_created) % MMOWriter::VOTE_TIMEOUT))})
      end
      
      app.get '/w/:id/ajax_on_refresh' do
        content_type :json
        cache_control :no_cache, :no_store
        
        story = MMOWriter::Story[params[:id]]
        JSON.generate({'s' => story.completed, 
                       'v' => !story.votes_dataset.where(:uuid => request.cookies['u']).empty?,
                       'b' => Rack::Utils.escape_html(story.body(50))})
      end
      
      app.post '/w/:id' do
        story = MMOWriter::Story[params[:id]]
        # Process vote
        # First, error if user has already voted
        raise 'you have already voted' if !story.votes_dataset.where(:uuid => request.cookies['u']).empty?
        
        # Error if story is complete
        raise 'this story is no longer accepting votes' if story.completed == 1
        
        # Error if input is invalid
        raise 'invalid action type' if !['word', 'special_start_char', 'special_end_char', 'paragraph', 'story_end'].include? params[:type]
        
        # Do more validation and finally enter the vote
        case params[:type]
        when 'word'
          word = params[:metadata].split(' ')[0]
          raise 'word too short' if word.nil?
          ['?', '!', '.', '"', "'", '(', ')', '[', ']', ':', ';', '<', '>'].each {|c| word.gsub! c, ''}
          raise 'word too short' if word.length < 1
          
          # cast vote
          story.add_vote :action_type => 'word', :action_metadata => word, :uuid => request.cookies['u']
        when 'special_end_char'
          raise 'invalid char type' if !['exclamation', 'question', 'period', 'comma', 'quotation close'].include? params[:metadata]
          # cast vote
          story.add_vote :action_type => 'special_end_char', :action_metadata => params[:metadata], :uuid => request.cookies['u']
        when 'special_start_char'
          raise 'invalid char type' if params[:metadata] != 'quotation open'
          # cast vote
          story.add_vote :action_type => 'special_start_char', :action_metadata => params[:metadata], :uuid => request.cookies['u']
        else
          # cast vote without metadata
          story.add_vote :action_type => params[:type], :action_metadata => '', :uuid => request.cookies['u']
        end
        
        'vote casted'
      end
    end
  end
end