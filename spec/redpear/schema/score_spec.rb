require 'spec_helper'

describe Redpear::Schema::Score do

  subject do
    described_class.new Comment, :rank
  end

  it { is_expected.to be_a(Redpear::Schema::Index) }

  it 'should return members store for a record' do
    expect(subject.for(nil)).to be_instance_of(Redpear::Store::SortedSet)
    expect(subject.for("ignored").key).to eq("comments:~:rank")
  end

  it 'should return members store' do
    expect(subject.members.key).to eq("comments:~:rank")
    expect(subject.members).to be_instance_of(Redpear::Store::SortedSet)
    expect(subject.members).to be_empty
  end

end