module MMOWriter::Routes
  module WriteStory
    def self.registered app     
      app.get '/w/:id' do
        erb :write_story, :locals => {:story => MMOWriter::Story[params[:id]]}, :layout => :global
      end
      
      app.get '/w/:id/votes' do
        story = MMOWriter::Story[params[:id]]
        votes = {}
        
        story.votes.each do |vote|
          vote_hash = {:type => vote.action_type, :metadata => vote.action_metadata}
          votes[vote_hash] = 0 if votes[vote_hash].nil?
          votes[vote_hash] += 1
        end
        popular_votes = votes.sort_by {|_, v| v}
        my_vote = story.votes.find{|v| v.uuid == request.cookies['u']}
        if !my_vote.nil?
          my_vote = [{:type => my_vote.action_type, :metadata => my_vote.action_metadata}, votes[{:type => my_vote.action_type, :metadata => my_vote.action_metadata}]]
        end
        popular_votes = popular_votes[-5 .. -1] if popular_votes.length > 5
        
        JSON.generate({'popular_votes' => popular_votes, 'my_vote' => my_vote})
      end
    end
  end
end