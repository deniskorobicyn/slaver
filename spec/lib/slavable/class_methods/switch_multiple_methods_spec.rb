require 'spec_helper'

class ClassMultipleMethods
  def self.test1
    Bar.create
  end

  class << self
    extend Slavable

    switch :test1, :test2, to: :other
  end

  def self.test2
    Foo.create
  end
end

describe 'switch' do
  context 'on class methods' do
    context 'when multiple methods defined' do
      let(:example) { ClassMultipleMethods }
      it 'switches test1 and test2 to other connection' do
        example.test1
        example.test2

        expect(Bar.count).to eq 0
        expect(Bar.on(:other).count).to eq 1
        expect(Foo.count).to eq 0
        expect(Foo.on(:other).count).to eq 1
      end
    end
  end
end
