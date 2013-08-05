require 'data_mapper'

class Token
  include DataMapper::Resource
  property :id, Serial
  property :content, Text, :required => true

  belongs_to :linked_in_user
end