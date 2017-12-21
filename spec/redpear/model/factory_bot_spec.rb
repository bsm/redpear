require 'spec_helper'

describe Redpear::Model::FactoryBot do

  let :klass do
    Redpear::Model
  end

  it 'should persist records on create' do
    created = FactoryBot.create(:post)
    expect(created).to eq({ 'id' => created.id })
    expect(created.attributes).to eq({ "title" => "A Title", "created_at" => "1313131313" })
  end

  it 'should persist records on build' do
    built = FactoryBot.build(:post)
    expect(built).to eq({ 'id' => built.id })
    expect(built.attributes).to eq({ "title" => "A Title", "created_at" => "1313131313" })
  end

end
