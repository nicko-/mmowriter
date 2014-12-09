module MMOWriter::Models
  class Vote < Sequel::Model(:votes)
    many_to_one :story
  end
end