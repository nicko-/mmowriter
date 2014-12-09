module MMOWriter
  class Action < Sequel::Model(:actions)
    many_to_one :story
  end
end