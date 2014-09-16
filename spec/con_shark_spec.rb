require 'spec_helper'
require 'con_shark_helper'
require 'con_shark'

include ConSharkHelper

def get_linked_in_user
  linked_in_user = LinkedInUser.new
  linked_in_user.id = 'id'
  linked_in_user.linked_in_id = 'linked_in_id'
  linked_in_user.name = 'test'
  linked_in_user
end

describe ConSharkHelper do
  it 'should convert hash into get params correctly' do
    test_hash = {'k1' => 'v1', 'k2' => 'v2'}
    expected_string = 'k1=v1&k2=v2'
    ConSharkHelper.generate_get_params(test_hash).should == expected_string
  end

  it 'should make a new user and add a connection if that user didn\'t previously exist' do
    full_user_list = []
    linked_in_user = get_linked_in_user

    connection_object = OpenStruct.new({'distance' => 1, 'name' => 'test'})
    returned_user = ConSharkHelper.add_connection_to_user(full_user_list, connection_object, linked_in_user)

    returned_user.user.should == linked_in_user
    returned_user.connections_with_distance(1).should == [connection_object]
  end

  it 'should get already existing user instead of creating one when exists in user list' do
    linked_in_user = get_linked_in_user

    already_existing_user = User.new(linked_in_user)
    connection_object1 = OpenStruct.new({'distance' => 1, 'name' => 'test1'})
    already_existing_user.add_connection connection_object1
    full_user_list = [already_existing_user]

    connection_object2 = OpenStruct.new({'distance' => 1, 'name' => 'test2'})
    returned_user = ConSharkHelper.add_connection_to_user(full_user_list, connection_object2, linked_in_user)

    returned_user.user.should == linked_in_user
    returned_user.connections_with_distance(1).should == [connection_object1, connection_object2]
  end

  it 'should get users of different distances correctly' do
    linked_in_user = get_linked_in_user

    full_user_list = []

    ConSharkHelper.add_connection_to_user(full_user_list, OpenStruct.new({'distance' => 1, 'name' => 'test2'}), linked_in_user)
    ConSharkHelper.add_connection_to_user(full_user_list, OpenStruct.new({'distance' => 2, 'name' => 'test2'}), linked_in_user)
    returned_user = ConSharkHelper.add_connection_to_user(full_user_list, OpenStruct.new({'distance' => 2, 'name' => 'test2'}), linked_in_user)

    returned_user.user.should == linked_in_user
    returned_user.connections_with_distance(1).size.should == 1
    returned_user.connections_with_distance(2).size.should == 2
  end
end
