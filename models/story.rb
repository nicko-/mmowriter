module MMOWriter
  class Story < Sequel::Model(:stories)
    one_to_many :actions
    one_to_many :votes
  
    def body words = nil
      # returns body of story
      #  words: amount of words from end of story to return
      actions = Action.where(:story_id => id)
      if !words.nil?
        actions = actions.to_a
        actions = actions[-words .. -1] if words < actions.length
      end
      
      # create a string from actions in the dataset
      story_body = ''
      actions.each do |action|
        case action.type
        when 'word'
          story_body += "#{action.metadata} "
        when 'special_end_char'
          story_body.chomp! ' ' # remove trailing space if it exists
          story_body += "#{action.metadata} "
        when 'special_start_char'
          story_body += action.metadata
        when 'paragraph'
          story_body.chomp! ' ' # remove trailing space if it exists
          story_body += "\n\n" # add two newlines for new paragraph
        when 'story_end'
          break # end of story, break
        end
      end
      
      story_body
    end
    
    def most_popular_action
      return nil if votes.length < 1
      
      votes_tally = {}
      votes.each do |vote|
        vote_hash = {:type => vote.action_type, :metadata => vote.action_metadata}
        votes_tally[vote_hash] = 0 if votes_tally[vote_hash].nil?
        votes_tally[vote_hash] += 1
      end
      votes_tally.sort_by {|_, v| v}.last[0]
    end
    
    def execute_most_popular_action_and_clear
      action = most_popular_action
      add_action action if !action.nil?
      votes.each {|v| v.delete}
    end
  end
end