require 'spec_helper'

describe Redpear::Model::Machinist do

  let :klass do
    Redpear::Model
  end

  it 'should extend Redpear Model' do
    expect(klass.blueprint_class).to eq(Redpear::Model::Machinist::Blueprint)
  end

  it 'should persist on make!' do
    made = Post.make!
    expect(made).to eq({ "id" => made.id })
    expect(made.attributes).to eq({ "title" => "A Title", "created_at" => "1313131313" })
  end

  it 'should also persist on make' do
    made = Post.make
    expect(made).to eq({ "id" => made.id })
    expect(made.attributes).to eq({ "title" => "A Title", "created_at" => "1313131313" })
  end

end
