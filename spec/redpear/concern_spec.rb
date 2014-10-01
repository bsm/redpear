require 'spec_helper'

describe Redpear::Concern do

  let :concernable do
    mod = Module.new

    mod.module_eval do
      extend Redpear::Concern
      def i_method
        :i
      end
    end

    module mod::ClassMethods
      def c_method
        :c
      end
    end

    mod
  end

  subject do
    mod   = self.concernable
    klass = Class.new
    klass.class_eval do
      include mod
    end
    klass.new
  end

  it 'should extend instance methods' do
    expect(subject).to respond_to(:i_method)
    expect(subject).not_to respond_to(:c_method)
    expect(subject.i_method).to eq(:i)
  end

  it 'should extend class methods' do
    expect(subject.class).to respond_to(:c_method)
    expect(subject.class).not_to respond_to(:i_method)
    expect(subject.class.c_method).to eq(:c)
  end

end