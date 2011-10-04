require 'spec_helper'
require 'redpear/core_ext/stringify_keys'

describe "Hash#stringify_keys" do

  subject do
    { :a => 1, "b" => 2 }
  end

  it 'should convert all non-string keys to strings' do
    new_hash = subject.stringify_keys
    new_hash.should == { "a" => 1, "b" => 2 }
    new_hash.should_not be(subject)
  end

  it 'should convert all non-string keys to strings destructively' do
    new_hash = subject.stringify_keys!
    new_hash.should == { "a" => 1, "b" => 2 }
    new_hash.should be(subject)
  end

end