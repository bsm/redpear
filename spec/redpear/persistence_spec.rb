require 'spec_helper'

describe Redpear::Persistence do

  let :new_instance do
    Post.new :title => 'A'
  end

  let :blank_instance do
    Post.new :id => 456
  end

  let :indexable_instance do
    Comment.new :id => 123, :post_id => 456
  end

  subject do
    Post.new :id => 123, :title => 'B', :created_at => Time.at(1313131313)
  end

  describe "new records" do
    subject { new_instance }
    it { should be_new_record }
    it { should_not be_persisted }
  end

  describe "existing records" do
    it { should_not be_new_record }
    it { should be_persisted }
  end

  it 'should reload records' do
    subject.save
    subject.update "name" => "C"
    subject.tap(&:reload).should == { "id" => "123", "title" => "B", "votes" => nil, "body" => nil, "created_at" => "1313131313" }
  end

  describe "saving" do

    it 'should generate new ID unless ID is present' do
      lambda {
        new_instance.save
      }.should change {
        connection.get('posts:+')
      }.from(nil).to("1")
      new_instance.nest.should == "posts:1"
    end

    it 'should save the item' do
      lambda {
        subject.save.should == subject
      }.should change { subject.nest.exists }.from(false).to(true)
      subject.nest.mapped_hmget_all.should == { 'title' => 'B', "created_at" => "1313131313" }
    end

    it 'should save "blank" instances' do
      lambda {
        blank_instance.save.should == blank_instance
      }.should change { blank_instance.nest.exists }.from(false).to(true)
    end

    it 'should store the ID in the members index' do
      lambda {
        subject.save
      }.should change { subject.class.members }.from([]).to(['123'])
    end

    it 'should store the ID in column indexes' do
      indexable_instance.save
      connection.keys.should =~ ["comments:123", "comments:*", "comments:post_id:456"]
      connection.get('comments:post_id:456').should == ['123'].to_set
    end

    it 'should NOT store the ID in column indexes if column value is empty' do
      subject.save
      connection.keys.should =~ ["posts:123", "posts:*"]
    end

    it 'should allow to expire on save' do
      subject.save :expire => 3600
      subject.ttl.should > 0
      subject.ttl.should <= 3600
    end

    it 'should allow to pass a custom block into the save transaction' do
      subject.save { expire(3600) }
      subject.ttl.should > 0
      subject.ttl.should <= 3600
    end

    it 'should allow shortcut-save records' do
      saved = nil
      lambda {
        saved = Post.save :name => 'A', :id => 1234
      }.should change { subject.class.members }.from([]).to(['1234'])

      saved.should be_a(Post)
      saved.nest.should == "posts:1234"
      saved.nest.mapped_hmget_all.should == { 'name' => 'A' }
    end

  end

  describe "destroying" do

    before do
      subject.save
    end

    it 'should not destroy if not persisted' do
      new_instance.destroy.should be(false)
    end

    it 'should destroy persisted' do
      lambda {
        subject.destroy.should be(true)
      }.should change { subject.nest.exists }.from(true).to(false)
    end

    it 'should remove ID from the members index' do
      lambda {
        subject.destroy
      }.should change { subject.class.members }.from(['123']).to([])
    end

    it 'should remove ID from column indices' do
      indexable_instance.save
      connection.get('comments:post_id:456').should have(1).item

      indexable_instance.destroy
      connection.get('comments:post_id:456').should be_empty
    end

    it 'should allow shortcut-destroy records' do
      lambda {
        Post.destroy(subject.id)
      }.should change { subject.class.members }.from(['123']).to([])
    end

  end
end