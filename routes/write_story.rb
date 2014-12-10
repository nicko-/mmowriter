module MMOWriter::Routes
  module WriteStory
    def self.registered app     
      app.get '/w/:id' do
        redirect to("/a/#{params[:id]}") if MMOWriter::Story[params[:id]].completed == 1
        erb :write_story, :locals => {:story => MMOWriter::Story[params[:id]]}, :layout => :global
      end
      
      app.get '/w/:id/votes' do
        story = MMOWriter::Story[params[:id]]
        votes = {}
        
        return 'no votes yet' if story.votes.length < 1
        
        story.votes.each do |vote|
          vote_hash = {:type => vote.action_type, :metadata => vote.action_metadata}
          votes[vote_hash] = 0 if votes[vote_hash].nil?
          votes[vote_hash] += 1
        end
        popular_votes = votes.sort_by {|_, v| v}
        popular_votes = popular_votes[-5 .. -1] if popular_votes.length > 5
        
        out = ''
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
          out += "<button type=\"button\" class=\"user_input_button#{color_string}\" onclick=\"postVote('#{vote[0][:type]}', '#{vote[0][:metadata]}')\"> #{vote[1]} vote#{'s' if vote[1] != 1} | " + text + "</button> "
        end        
        out
      end
      
      app.post '/w/:id' do
        story = MMOWriter::Story[params[:id]]
        # Process vote
        # First, error if user has already voted
        raise 'you have already voted' if !story.votes_dataset.where(:uuid => request.cookies['u']).empty?
        
        # Error if input is invalid
        raise 'invalid action type' if !['word', 'special_start_char', 'special_end_char', 'paragraph', 'story_end'].include? params[:type]
        
        # Do more validation and finally enter the vote
        case params[:type]
        when 'word'
          word = params[:metadata].split(' ')[0]
          raise 'word too short' if word.nil?
          ['?', '!', '.', '"', "'", '(', ')', '[', ']', ':', ';'].each {|c| word.gsub! c, ''}
          raise 'word too short' if word.length < 1
          
          # cast vote
          story.add_vote :action_type => 'word', :action_metadata => word, :uuid => request.cookies['u']
        when 'special_end_char'
          raise 'invalid char type' if !['exclamation', 'question', 'period', 'quotation close'].include? params[:metadata]
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
        
        redirect to("/w/#{params[:id]}") # Redirect to GET /w/id
      end
    end
  end
end