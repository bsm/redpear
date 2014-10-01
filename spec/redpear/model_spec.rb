require 'spec_helper'

describe Redpear::Model do

  describe "connection" do

    it 'should have a default' do
      expect(User.connection).to be_instance_of(Redis)
    end

    it 'can have a custom' do
      expect(Manager.connection).to be_instance_of(ManagerConnection)
    end

    it 'should be inheritable' do
      expect(Employee.connection).to be(User.connection)
    end

    it 'should be overridable' do
      expect(User).to respond_to(:connection=)
    end

  end

  describe "model" do
    subject { Post }

    it 'should have members' do
      expect(subject.members).to be_instance_of(Redpear::Store::Set)
      expect(subject.members).to eq([])
    end

    it 'should have a PK counter' do
      expect(subject.pk_counter).to be_instance_of(Redpear::Store::Counter)
      expect(subject.pk_counter.next).to eq(1)
    end

    it 'should have a create alias for new' do
      expect(subject.create).to be_instance_of(subject)
    end

    it 'should have a scope' do
      expect(subject.scope).to eq("posts")
    end

    it 'can have a custom scope' do
      expect(Manager.scope).to eq("execs")
    end

    it 'should build nested keys' do
      expect(subject.nested_key(1, 2, "X")).to eq("posts:1:2:X")
    end

    it 'should allow transactions' do
      subject.pk_counter
      subject.transaction do
        subject.pk_counter.next
        subject.pk_counter.next
        subject.pk_counter.next
      end
      expect(subject.pk_counter).to eq(3)

      Post.transaction do
        Post.new :id => 1, :title => "A", :rank => 1, :user_id => 1
        Post.new :id => 2, :title => "A", :rank => 2, :user_id => 2
      end
      expect(Post.count).to eq(2)
    end

  end

  it { is_expected.to be_a(Hash) }

  it 'should be comparable' do
    expect(Post.new(:id => 1)).to eq(Post.new(:id => 1))
    expect(Post.new(:id => 1)).to eq(Post.new(:id => 1, :title => nil))
    expect(Post.new(:id => 1, :title => "A")).to eq(Post.new(:id => 1, :title => "B"))
    expect(Post.new(:id => 999)).not_to eq(Post.new)
    expect(Post.new(:id => 1)).not_to eq(Post.new(:id => 2))

    expect(Post.new).not_to eq(Post.new)
    expect(Post.new).not_to eq(Comment.new)
    expect(Post.new(:id => 1)).not_to eq(Comment.new(:id => 1))
  end

  it 'should allow clearing attribute cache' do
    post = Post.new(:id => 1, :title => 'A Title')
    post.title
    expect(post).to eq({'id' => '1', 'title' => 'A Title'})
    expect(post.clear).to eq({'id' => '1'})
    expect(post).to eq({'id' => '1'})
  end

  it 'should give access to raw attributes' do
    post = Post.new(:id => 1, :title => 'A Title')
    expect(post.attributes).to be_instance_of(Redpear::Store::Hash)
    expect(post.attributes).to eq({ 'title' => 'A Title' })
    expect(post.attributes.to_s).to eq("posts::1")
  end

  it 'should give access to raw lookups' do
    post = Post.new(:id => 1, :title => 'A Title', :user_id => 2)
    expect(post.lookups.count).to eq(3)
    expect(post.lookups.map(&:to_s)).to match_array(["posts:~", "posts:~:rank", "posts:~:user_id:2"])
  end

  describe "initialization" do

    it 'should initialize with ID' do
      expect(subject).to eq({ 'id' => described_class.pk_counter.value.to_s })
    end

    it 'should initialize with custom ID' do
      expect(described_class.new('id' => 123)).to eq({ 'id' => '123' })
      expect(described_class.new(:id => '123')).to eq({ 'id' => '123' })
    end

    it 'should initialize with attributes' do
      expect(Post.new('id' => 1, :title => "A Title").attributes).to eq({ 'title' => 'A Title' })
      expect(Post.new('id' => 2, :title => "A Title", :ignore => 'me').attributes).to eq({ 'title' => 'A Title' })
      expect(Post.new('id' => 3, :rank => "10", :ignore => 'me').attributes).to eq({})
      expect(Post.columns[:rank].members).to eq([["3", 10]])
    end

  end

  describe "single attributes" do
    subject { Post.new(:id => 1) }

    it 'should read & cache single attributes' do
      Post.new(:id => 1, :title => 'A Title')
      expect(subject).to eq({'id' => '1'})
      expect(subject['title']).to eq('A Title')
      expect(subject).to eq({'id' => '1', 'title' => 'A Title'})

      subject.attributes['title'] = 'New Title'
      expect(subject['title']).to eq('A Title')
    end

    it 'should read & cache single scores' do
      Post.new(:id => 1, :rank => 10)
      expect(subject).to eq({'id' => '1'})
      expect(subject['rank']).to eq(10)
      expect(subject).to eq({'id' => '1', 'rank' => 10})

      Post.columns['rank'].members[1] = 20
      expect(subject['rank']).to eq(10)
    end

    it 'should write single attributes' do
      expect(subject).to eq({'id' => '1'})
      subject['title'] = 'New Title'
      expect(subject).to eq({'id' => '1'})
      subject.attributes == {'title' => 'New Title'}
      expect(subject.title).to eq('New Title')
    end

    it 'should write single indicies' do
      expect(subject).to eq({'id' => '1'})
      subject['user_id'] = 123
      expect(subject).to eq({ 'id' => '1' })
      subject.attributes == { 'user_id' => '123' }
      expect(Post.columns['user_id'].members(123)).to eq(["1"])
      expect(subject.user_id).to eq("123")
    end

    it 'should NOT write indicies if NULL' do
      expect(subject).to eq({'id' => '1'})
      subject['user_id'] = nil
      expect(Post.columns['user_id'].members(nil)).to eq([])
    end

    it 'should write single scores' do
      expect(subject).to eq({'id' => '1'})
      subject['rank'] = 10
      expect(subject).to eq({ 'id' => '1' })
      subject.attributes == {}
      expect(Post.columns['rank'].members[1]).to eq(10)
      expect(subject.rank).to eq(10)
    end

    it 'should NOT write scores if NULL' do
      expect(subject).to eq({'id' => '1'})
      subject['rank'] = nil
      expect(Post.columns['rank'].members[1]).to be_nil
    end

  end

  describe "bulk update" do
    subject { Post.new(:id => 1).update(:title => 'A Title', :rank => 10, :user_id => 2) }

    it 'should update columns' do
      expect(subject.attributes).to eq({"title"=>"A Title", "user_id"=>"2"})
      expect(subject.title).to eq("A Title")
    end

    it 'should update indicies' do
      expect(subject.attributes).to eq({"title" => "A Title", "user_id" => "2"})
      expect(subject.user_id).to eq("2")
      expect(Post.columns['user_id'].members('2')).to eq([subject.id])
    end

    it 'should NOT update indicies if NULL' do
      post = Post.new :id => 2
      expect(post.user_id).to be_nil
      expect(Post.columns['user_id'].members(nil)).to eq([])
    end

    it 'should update scores' do
      expect(subject.attributes).to eq({"title"=>"A Title", "user_id"=>"2"})
      expect(subject.user_id).to eq("2")
      expect(Post.columns['rank'].members[subject.id]).to eq(10)
    end

    it 'should NOT update scores if NULL' do
      post = Post.new :id => 2
      expect(post.rank).to be_nil
      expect(Post.columns['rank'].members[post.id]).to be_nil
    end

    it 'should clear cache' do
      subject.title
      expect(subject).to eq({"id" => "1", "title"=>"A Title"})
      subject.update('rank' => 5)
      expect(subject).to eq({"id" => "1"})
      expect(Post.columns['rank'].members[subject.id]).to eq(5)
    end

  end

  describe "incrementation" do
    subject    { Post.new(:id => 1) }
    let(:post) { Post.new(:id => 1, :votes => 10) }

    it 'should increment counters' do
      expect(subject.increment('votes')).to eq(1)
      expect(subject).to eq({'id' => '1', 'votes' => 1})
      subject.increment 'votes', 5
      expect(subject).to eq({'id' => '1', 'votes' => 6})
    end

    it 'should decrement counters' do
      expect(post.decrement('votes')).to eq(9)
      expect(post).to eq({'id' => '1', 'votes' => 9})
      post.decrement 'votes', 5
      expect(post).to eq({'id' => '1', 'votes' => 4})
    end

    it 'should not in/decrement non-counters' do
      expect(subject.increment('title')).to be(false)
      expect(subject).to eq({'id' => '1'})
    end

  end

  describe "destroying" do
    subject { Post.new :id => 1, :user_id => 5, :rank => 20 }

    it 'should destroy records' do
      expect {
        expect(subject.destroy).to eq(subject)
      }.to change { subject.class.exists?(subject.id) }.from(true).to(false)
    end

    it 'should remove ID from the members index' do
      expect {
        subject.destroy
      }.to change { subject.class.members.to_a }.from(['1']).to([])
    end

    it 'should remove ID from index lookups' do
      lookup = subject.class.columns[:user_id].members('5')
      expect {
        subject.destroy
      }.to change { lookup.to_a }.from(['1']).to([])
    end

    it 'should remove ID from scores' do
      lookup = subject.class.columns[:rank].members
      expect {
        subject.destroy
      }.to change { lookup.to_a }.from([['1', 20]]).to([])
    end

    it 'should allow shortcut-destroy records' do
      expect {
        Post.destroy(subject.id)
      }.to change { subject.class.exists?(subject.id) }.from(true).to(false)
    end

    it 'should freeze destroyed records' do
      subject.destroy
      expect(subject).to be_frozen
    end

    it 'should prevent users from modifying destroyed records' do
      subject.destroy
      expect(subject['title']).to be_nil
      expect { subject['title'] = "New Title" }.to raise_error(RuntimeError, /frozen/)
      expect { subject.update 'title' => "New Title" }.to raise_error(RuntimeError, /frozen/)
    end

  end
end
