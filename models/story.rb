module MMOWriter::Models
  class Story < Sequel::Model(:story_metadata)
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
  end
end