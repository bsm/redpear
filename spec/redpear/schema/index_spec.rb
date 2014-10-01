require 'spec_helper'

describe Redpear::Schema::Index do

  subject do
    described_class.new Comment, :post_id
  end

  it { is_expected.to be_a(Redpear::Schema::Column) }

  it 'should return members store for a record' do
    comment = Comment.new :post_id => 100
    expect(subject.for(comment)).to be_instance_of(Redpear::Store::Set)
    expect(subject.for(comment).key).to eq("comments:~:post_id:100")
  end

  it 'should return blank members store for a record without values' do
    comment = Comment.new
    expect(subject.for(comment)).to be_instance_of(Redpear::Store::Set)
    expect(subject.for(comment).key).to eq("comments:~:post_id:_")
  end
  it 'should return members store for a value' do
    expect(subject.members(200).key).to eq("comments:~:post_id:200")
    expect(subject.members(200)).to be_instance_of(Redpear::Store::Set)
    expect(subject.members(200)).to eq([])
    subject.members(200).add 1
    expect(subject.members(200)).to eq(["1"])
    expect(subject.members(nil)).to eq([])
  end

end