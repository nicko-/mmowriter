module MMOWriter::Models
  class Story
    def self.create
      # Creates a story in the database, and returns a Story object
      id = MMOWriter::DB[:story_metadata].insert :date_created  => Time.now.utc.to_i,
                                                       :completed     => 0,
                                                       :archive_votes => 0
      Story[id]
    end
    
    def self.[] id
      raise 'no such story' if MMOWriter::DB[:story_metadata].where(:id => id).empty?
      Story.new id
    end
    
    attr_reader :id, :date_created
    
    def initialize id
      @id = id
      # Cache date_created, as it never changes.
      @date_created = MMOWriter::DB[:story_metadata].where(:id => id).first[:date_created]
    end
    
    def completed
      MMOWriter::DB[:story_metadata].where(:id => @id).first[:completed] == 1
    end
    
    def completed= value
      MMOWriter::DB[:story_metadata].where(:id => @id).update :completed => value ? 1 : 0
      if value
        MMOWriter::DB[:story_metadata].where(:id => @id).update :date_completed => Time.now.utc.to_i
      end
    end
  end
end