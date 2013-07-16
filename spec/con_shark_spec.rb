require 'spec_helper'
require 'con_shark_helper'

include ConSharkHelper

describe ConSharkHelper do
    it 'should convert hash into get params correctly' do
        test_hash = {'k1' => 'v1', 'k2' => 'v2'}
        expected_string = 'k1=v1&k2=v2'
        ConSharkHelper.generate_get_params(test_hash).should == expected_string
    end
end
