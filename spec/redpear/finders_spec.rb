require 'spec_helper'

describe Redpear::Finders do

  subject do
    Post.new
  end

  before do
    (1..3).each do |id|
      Post.save(:id => id, :title => "A", :body => "B")
    end
  end

  it { subject.should be_a(described_class) }

  it 'should retrieve members' do
    subject.class.members.should be_a(Redpear::Members)
    subject.class.members.to_a.should =~ ["1", "2", "3"]
  end

  it 'should have a count' do
    subject.class.count.should == 3
  end

  it 'should retrieve all records' do
    Post.find(3).expire(Time.now)
    subject.class.all.should have(2).items
    subject.class.all.first.should be_a(Post)
  end

  it 'should find each record' do
    Post.find(3).expire(Time.now)
    res = []
    subject.class.find_each do |record|
      res << record.id
    end
    res.should =~ ["1", "2"]
  end

  it 'should find individual records' do
    subject.class.find(1).should be_a(Post)
    subject.class.find(1).should == { "id" => "1" }
    subject.class.find(1).to_hash.should == { "id" => "1", "title" => "A", "body" => "B", "votes" => nil, "created_at" => nil, "user_id"=>nil }
    subject.class.find(100).should be_nil
  end

  it 'should find individual records (and load instanly)' do
    subject.class.find(1, :lazy => false).should be_a(Post)
    subject.class.find(1, :lazy => false).should == { "id" => "1", "title" => "A", "body" => "B", "votes" => nil, "created_at" => nil, "user_id"=>nil }
  end

  it 'should not find expired records' do
    record = subject.class.find(1)
    record.expire(-3600)
    subject.class.find(1).should be_nil
  end

  it 'should check existance of individual records' do
    subject.class.exists?(1).should be(true)
    subject.class.exists?(100).should be(false)
  end

end