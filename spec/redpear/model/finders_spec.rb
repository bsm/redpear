require 'spec_helper'

describe Redpear::Model::Finders do

  it 'should have a count' do
    5.times { Post.new }
    Post.count.should == 5
  end

  it 'should check if a record exists' do
    Post.exists?(Post.new.id).should be(true)
    Post.exists?(nil).should be(false)
    Post.exists?(1234).should be(false)
  end

  it 'should find individual records' do
    post = Post.new :title => 'A Title'
    Post.find(post.id).should be_a(Post)
    Post.find(post.id).should == post
    Post.find(post.id).should == { 'id' => post.id }
    Post.find(nil).should be_nil
    Post.find(1234).should be_nil
  end

  it 'should find all records' do
    p1, p2  = Post.new(:title => 'A Title'), Post.new(:title => 'B Title')
    Post.all.should =~ [p1, p2]
  end

  it 'should find each record' do
    p1, p2  = Post.new(:title => 'A Title'), Post.new(:title => 'B Title')
    yielded = []
    Post.find_each {|i| yielded << i }
    yielded.should =~ [p1, p2]
  end

end
