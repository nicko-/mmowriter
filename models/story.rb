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
          case action.metadata
          when 'exclamation'
            story_body += '! '
          when 'question'
            story_body += '? '
          when 'period'
            story_body += '. '
          when 'quotation close'
            story_body += '" '
          end
        when 'special_start_char'
          case action_metadata
          when 'quotation open'
            story_body += '"'
          end
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
      
      if !action.nil? && action[:type] == 'story_end'
        update :completed => true, :date_completed => Time.now.utc.to_i # Set current story as complete
        Story.create :date_created => Time.now.to_i, :completed => false, :archive_votes => 0 # Create new story
      end
    end
  end
end