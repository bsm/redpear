require 'spec_helper'

describe Redpear::Schema do

  subject do
    klass = Class.new(Redpear::Model)
    klass.class_eval do
      def self.name
        "User"
      end
    end
    klass
  end

  let :post do
    Post.new
  end

  let :comment do
    Comment.new
  end

  it 'should maintain a column registry' do
    subject.columns.should be_a(described_class::Collection)
  end

  it 'should define/store columns' do
    lambda {
      subject.column "name"
    }.should change { subject.columns.dup }.from([]).to(["name"])
  end

  it 'should define/store indices' do
    lambda {
      subject.index "name"
    }.should change { subject.columns.dup }.from([]).to(["name"])
  end

  it 'should create attribute accessor methods' do
    post.title.should be_nil
    post.votes.should == 0
    comment.post_id.should be_nil

    post.title = "A"
    post.should_not respond_to(:votes=)
    comment.post_id = 123

    post.title.should == "A"
    post.votes.should == 0
    comment.post_id.should == 123
  end

end