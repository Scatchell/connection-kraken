require 'spec_helper'
require 'rspec'

require 'user'
require 'linked_in_user'

describe 'My behaviour' do

  it 'should retrieve connections based on distance' do
    linked_in_user = LinkedInUser.new
    linked_in_user.id = 'id'
    linked_in_user.linked_in_id = 'linked_in_id'
    linked_in_user.name = 'test'

    user = User.new(linked_in_user)
    test_user = OpenStruct.new({'distance' => 2, 'firstName' => 'Jenna', 'id' => 'mEqw1-GgLN', 'lastName' => 'Hall', 'pictureUrl' => 'http://m.c.lnkd.licdn.com/mpr/mprx/0_WTL7meUCtjpXUKPIw39rmIJu-0IwMzPIIQArmIoxDV0UQlkwLbz_hwYlplwNV-tFeCFlTuZZO3yi'})
    user.add_connection test_user

    user.connections_with_distance(2).should == [test_user]
  end
end