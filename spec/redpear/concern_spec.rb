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
    subject.should respond_to(:i_method)
    subject.should_not respond_to(:c_method)
    subject.i_method.should == :i
  end

  it 'should extend class methods' do
    subject.class.should respond_to(:c_method)
    subject.class.should_not respond_to(:i_method)
    subject.class.c_method.should == :c
  end

end