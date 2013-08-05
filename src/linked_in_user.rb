require 'data_mapper'

class LinkedInUser
  include DataMapper::Resource
  property :id, Serial
  property :linked_in_id, Text
  property :name, Text
  property :picture_url, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  has 1, :token
end