require 'spec_helper'

class ClassSwitchBefore
  class << self
    extend Slavable

    switch :some_method, to: :other
  end

  def self.some_method
    Foo.create
  end

  def some_method
    Bar.create
  end
end

describe 'switch' do
  context 'on class methods' do
    context 'when switch before method definition' do
      it 'switches some_method to other connection' do
        ClassSwitchBefore.some_method

        expect(Foo.count).to eq 0
        expect(Foo.on(:other).count).to eq 1
      end

      it 'do not swiches instance method to other connection' do
        ClassSwitchBefore.new.some_method

        expect(Bar.count).to eq 1
        expect(Bar.on(:other).count).to eq 0
      end
    end
  end
end
