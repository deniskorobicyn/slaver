require 'spec_helper'

class ClassSwitchAfter
  def self.some_method
    Foo.create
  end

  class << self
    extend Slavable

    switch :some_method, to: :other
  end
end

describe 'switch' do
  context 'on class methods' do
    context 'when switch after method definition' do
      it 'switches some_method to other connection' do
        ClassSwitchAfter.some_method

        expect(Foo.count).to eq 0
        expect(Foo.on(:other).count).to eq 1
      end
    end
  end
end
