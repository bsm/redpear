require 'spec_helper'

describe Redpear::Model::FactoryGirl do

  let :klass do
    Redpear::Model
  end

  it 'should persist records on create' do
    created = FactoryGirl.create(:post)
    created.should == { 'id' => created.id }
    created.attributes.should == { "title" => "A Title", "created_at" => "1313131313" }
  end

  it 'should persist records on build' do
    built = FactoryGirl.build(:post)
    built.should == { 'id' => built.id }
    built.attributes.should == { "title" => "A Title", "created_at" => "1313131313" }
  end

end
