module MMOWriter::Routes
  module WriteStory
    def self.registered app     
      app.get '/w/:id/' do
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
          out += "<button type=\"button\" class=\"user_input_button#{color_string}\"> #{vote[1]} vote#{'s' if vote[1] != 1} | " + text + "</button> "
        end        
        out
      end
    end
  end
end