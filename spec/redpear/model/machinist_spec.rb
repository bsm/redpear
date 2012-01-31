require 'spec_helper'

describe Redpear::Model::Machinist do

  let :klass do
    Redpear::Model
  end

  it 'should extend Redpear Model' do
    klass.blueprint_class.should == Redpear::Model::Machinist::Blueprint
  end

  it 'should persist on make!' do
    made = Post.make!
    made.should == { "id" => made.id }
    made.attributes.should == { "title" => "A Title", "created_at" => "1313131313" }
  end

  it 'should also persist on make' do
    made = Post.make
    made.should == { "id" => made.id }
    made.attributes.should == { "title" => "A Title", "created_at" => "1313131313" }
  end

end
