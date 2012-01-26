require 'spec_helper'

describe Redpear::Model do

  subject do
    Post.new
  end

  it { should be_a(Hash) }

  describe "connection" do

    it 'should have a default' do
      User.connection.should be_instance_of(Redpear::Connection)
    end

    it 'can have a custom' do
      Manager.connection.should be_instance_of(ManagerConnection)
    end

    it 'should be inheritable' do
      Employee.connection.should be(User.connection)
    end

    it 'should be overridable' do
      User.should respond_to(:connection=)
    end

  end

  describe "model" do

    it 'should have members' do
      subject.class.members.should be_instance_of(Redpear::Store::Set)
      subject.class.members.should == []
    end

    it 'should have a PK generator' do
      subject.class.pk_generator.should be_instance_of(Redpear::Store::Value)
      subject.class.pk_generator.next.should == 1
    end

  end

  it 'should initialize with attributes' do
    described_class.new(:id => 1).should == { "id" => "1" }
  end

  it 'should have an ID' do
    subject.id.should be_nil
    subject.update("id" => 123).id.should == '123'
  end

  it 'should allow to assign an ID' do
    subject.id = 123
    subject.id.should == '123'
  end

  it 'should be exportable to a real hash' do
    subject.to_hash.should == subject
    subject.to_hash.should be_instance_of(Hash)
  end

  it 'should have a custom inspect' do
    subject.inspect.should be_instance_of(String)
    subject.inspect.should_not be_empty
  end

  it 'should allow bulk updates' do
    subject.update("a" => 1, :b => 2, :id => 3).should == { "a" => 1, "b" => 2, "id" => "3" }
    subject.update(nil).should == { "a" => 1, "b" => 2, "id" => "3" }
  end

  it 'should be comparable' do
    Post.new(:id => 1).should == Post.new(:id => 1)
    Post.new(:id => 1).should == Post.new(:id => 1, :title => nil)
    Post.new(:id => 1, :title => "A").should == Post.new(:id => 1, :title => "B")
    Post.new(:id => 1).should_not == Post.new
    Post.new(:id => 1).should_not == Post.new(:id => 2)

    Post.new.should_not == Post.new
    Post.new.should_not == Comment.new
    Post.new(:id => 1).should_not == Comment.new(:id => 1)

    [Post.new(:id => 1), Post.new(:id => 2)].should =~ [Post.new(:id => 2), Post.new(:id => 1)]
  end

  it 'should allow to fetch attributes without type-casting' do
    subject.__fetch__('votes').should == nil
    subject['votes'].should == 0
  end

  it 'should read attributes with type-casting' do
    subject.__fetch__('votes').should == nil
    subject['votes'].should == 0
    subject.votes.should == 0
  end

  it 'should write attributes correctly' do
    subject[:title] = "A"
    subject.__fetch__("title").should == "A"

    subject['votes'].should == 0
    subject['votes'] = "1"
    subject['votes'].should == 1
  end

end