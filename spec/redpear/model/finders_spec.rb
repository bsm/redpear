require 'spec_helper'

describe Redpear::Model::Finders do

  it 'should have a count' do
    5.times { Post.new }
    expect(Post.count).to eq(5)
  end

  it 'should check if a record exists' do
    expect(Post.exists?(Post.new.id)).to be(true)
    expect(Post.exists?(nil)).to be(false)
    expect(Post.exists?(1234)).to be(false)
  end

  it 'should find individual records' do
    post = Post.new title: 'A Title'
    expect(Post.find(post.id)).to be_a(Post)
    expect(Post.find(post.id)).to eq(post)
    expect(Post.find(post.id)).to eq({ 'id' => post.id })
    expect(Post.find(nil)).to be_nil
    expect(Post.find(1234)).to be_nil
  end

  it 'should find all records' do
    p1, p2 = Post.new(title: 'A Title'), Post.new(title: 'B Title')
    expect(Post.all).to eq([p1, p2])
  end

  it 'should find each record' do
    p1, p2  = Post.new(title: 'A Title'), Post.new(title: 'B Title')
    yielded = []
    Post.find_each {|i| yielded << i }
    expect(yielded).to eq([p1, p2])
  end

end
