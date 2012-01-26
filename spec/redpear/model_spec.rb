require 'spec_helper'

describe Redpear::Model do

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
    subject { Post }

    it 'should have members' do
      subject.members.should be_instance_of(Redpear::Store::Set)
      subject.members.should == []
    end

    it 'should have a PK counter' do
      subject.pk_counter.should be_instance_of(Redpear::Store::Value)
      subject.pk_counter.next.should == 1
    end

    it 'should have a scope' do
      subject.scope.should == "posts"
    end

    it 'can have a custom scope' do
      Manager.scope.should == "execs"
    end

    it 'should build scopes' do
      subject.scoped(1, 2, "X").should == "posts:1:2:X"
    end

    it 'should allow transactions' do
      subject.transaction do
        subject.pk_counter.next
        subject.pk_counter.next
        subject.pk_counter.next
      end
      subject.pk_counter.value.should == "3"

      Post.transaction do
        Post.new :id => 1, :title => "A", :rank => 1, :user_id => 1
        Post.new :id => 2, :title => "A", :rank => 2, :user_id => 2
      end
      Post.count.should == 2
    end

  end

  describe "finders" do

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

  it { should be_a(Hash) }

  it 'should be comparable' do
    Post.new(:id => 1).should == Post.new(:id => 1)
    Post.new(:id => 1).should == Post.new(:id => 1, :title => nil)
    Post.new(:id => 1, :title => "A").should == Post.new(:id => 1, :title => "B")
    Post.new(:id => 999).should_not == Post.new
    Post.new(:id => 1).should_not == Post.new(:id => 2)

    Post.new.should_not == Post.new
    Post.new.should_not == Comment.new
    Post.new(:id => 1).should_not == Comment.new(:id => 1)

    [Post.new(:id => 1), Post.new(:id => 2)].should =~ [Post.new(:id => 2), Post.new(:id => 1)]
  end

  it 'should allow clearing attribute cache' do
    post = Post.new(:id => 1, :title => 'A Title')
    post.title
    post.should == {'id' => '1', 'title' => 'A Title'}
    post.clear.should == {'id' => '1'}
    post.should == {'id' => '1'}
  end

  it 'should allow have raw attributes' do
    post = Post.new(:id => 1, :title => 'A Title')
    post.attributes.should be_instance_of(Redpear::Store::Hash)
    post.attributes.should == { 'title' => 'A Title' }
  end

  describe "initialization" do

    it 'should initialize with ID' do
      subject.should == { 'id' => described_class.pk_counter.value }
    end

    it 'should initialize with custom ID' do
      described_class.new('id' => 123).should == { 'id' => '123' }
      described_class.new(:id => '123').should == { 'id' => '123' }
    end

    it 'should initialize with attributes' do
      Post.new('id' => 1, :title => "A Title").attributes.should == { 'title' => 'A Title' }
      Post.new('id' => 2, :title => "A Title", :ignore => 'me').attributes.should == { 'title' => 'A Title' }
      Post.new('id' => 3, :rank => "10", :ignore => 'me').attributes.should == {}
      Post.columns[:rank].members.should == [["3", 10]]
    end

  end

  describe "single attributes" do
    subject { Post.new(:id => 1) }

    it 'should read & cache single attributes' do
      Post.new(:id => 1, :title => 'A Title')
      subject.should == {'id' => '1'}
      subject['title'].should == 'A Title'
      subject.should == {'id' => '1', 'title' => 'A Title'}

      subject.attributes['title'] = 'New Title'
      subject['title'].should == 'A Title'
    end

    it 'should read & cache single scores' do
      Post.new(:id => 1, :rank => 10)
      subject.should == {'id' => '1'}
      subject['rank'].should == 10
      subject.should == {'id' => '1', 'rank' => 10}

      Post.columns['rank'].members[1] = 20
      subject['rank'].should == 10
    end

    it 'should write single attributes' do
      subject.should == {'id' => '1'}
      subject['title'] = 'New Title'
      subject.should == {'id' => '1'}
      subject.attributes == {'title' => 'New Title'}
      subject.title.should == 'New Title'
    end

    it 'should write single indicies' do
      subject.should == {'id' => '1'}
      subject['user_id'] = 123
      subject.should == { 'id' => '1' }
      subject.attributes == { 'user_id' => '123' }
      Post.columns['user_id'].members(123).should == ["1"]
      subject.user_id.should == "123"
    end

    it 'should write single scores' do
      subject.should == {'id' => '1'}
      subject['rank'] = 10
      subject.should == { 'id' => '1' }
      subject.attributes == {}
      Post.columns['rank'].members[1].should == 10
      subject.rank.should == 10
    end

  end

  describe "bulk update" do
    subject { Post.new(:id => 1).update(:title => 'A Title', :rank => 10, :user_id => 2) }

    it 'should update columns' do
      subject.attributes.should == {"title"=>"A Title", "user_id"=>"2"}
      subject.title.should == "A Title"
    end

    it 'should update indicies' do
      subject.attributes.should == {"title" => "A Title", "user_id" => "2"}
      subject.user_id.should == "2"
      Post.columns['user_id'].members('2').should == [subject.id]
    end

    it 'should update scores' do
      subject.attributes.should == {"title"=>"A Title", "user_id"=>"2"}
      subject.user_id.should == "2"
      Post.columns['rank'].members[subject.id].should == 10
    end

    it 'should clear cache' do
      subject.title
      subject.should == {"id" => "1", "title"=>"A Title"}
      subject.update('rank' => 5)
      subject.should == {"id" => "1"}
      Post.columns['rank'].members[subject.id].should == 5
    end

  end

  describe "incrementation" do
    subject    { Post.new(:id => 1) }
    let(:post) { Post.new(:id => 1, :votes => 10) }

    it 'should increment counters' do
      subject.increment('votes').should == 1
      subject.should == {'id' => '1', 'votes' => 1}
      subject.increment 'votes', 5
      subject.should == {'id' => '1', 'votes' => 6}
    end

    it 'should decrement counters' do
      post.decrement('votes').should == 9
      post.should == {'id' => '1', 'votes' => 9}
      post.decrement 'votes', 5
      post.should == {'id' => '1', 'votes' => 4}
    end

    it 'should not in/decrement non-counters' do
      subject.increment('title').should be(false)
      subject.should == {'id' => '1'}
    end

  end

  describe "expiration" do
    subject { Post.new :title => 'Any' }

    it 'should ignore invalid expire values' do
      subject.expire(nil).should be(false)
      subject.expire(false).should be(false)
      subject.expire("ABC").should be(false)
    end

    it 'should allow to expire records via timestamps' do
      subject.expire(Time.now + 3600).should be(true)
      subject.ttl.should > 0
      subject.ttl.should <= 3600
    end

    it 'should allow to expire records via numeric periods' do
      subject.expire(3600).should be(true)
      subject.ttl.should > 0
      subject.ttl.should <= 3600
    end

    it 'should return negative ttl for non-expiring records' do
      subject.ttl.should be_nil
    end

    it 'should return a positive ttl for expiring records' do
      subject.expire(30)
      subject.ttl.should > 0
    end
  end

  describe "destroying" do
    subject { Post.new :id => 1, :user_id => 5, :rank => 20 }

    it 'should destroy records' do
      lambda {
        subject.destroy.should be(true)
      }.should change { subject.class.exists?(subject.id) }.from(true).to(false)
    end

    it 'should remove ID from the members index' do
      lambda {
        subject.destroy
      }.should change { subject.class.members.to_a }.from(['1']).to([])
    end

    it 'should remove ID from index lookups' do
      lookup = subject.class.columns[:user_id].members('5')
      lambda {
        subject.destroy
      }.should change { lookup.to_a }.from(['1']).to([])
    end

    it 'should remove ID from scores' do
      lookup = subject.class.columns[:rank].members
      lambda {
        subject.destroy
      }.should change { lookup.to_a }.from([['1', 20]]).to([])
    end

    it 'should allow shortcut-destroy records' do
      lambda {
        Post.destroy(subject.id)
      }.should change { subject.class.exists?(subject.id) }.from(true).to(false)
    end

  end
end
