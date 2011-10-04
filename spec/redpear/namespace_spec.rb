require 'spec_helper'

describe Redpear::Namespace do

  subject do
    Post.new
  end

  describe "classes" do

    it 'should have a namespace' do
      subject.class.namespace.should be_instance_of(Redpear::Nest)
      subject.class.namespace.should == "posts"
    end

    it 'should have a members nest' do
      subject.class.mb_nest.should be_instance_of(Redpear::Nest)
      subject.class.mb_nest.should == "posts:*"
    end

    it 'should have a PK nest' do
      subject.class.pk_nest.should be_instance_of(Redpear::Nest)
      subject.class.pk_nest.should == "posts:+"
    end

    it 'should have a scope' do
      subject.class.scope.should == "posts"
    end

  end

  describe "instances" do
    it { subject.should be_a(described_class) }

    it 'should have a nest' do
      subject.nest.should be_instance_of(Redpear::Nest)
      subject.nest.should == "posts:_"
      subject.update("id" => 123).nest.should == "posts:123"
    end
  end

end