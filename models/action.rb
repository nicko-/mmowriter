module MMOWriter::Models
  class Action < Sequel::Model(:story_actions)
    many_to_one :story
  end
end