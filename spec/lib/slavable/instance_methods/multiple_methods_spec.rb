require 'spec_helper'

class MultipleMethods
  extend Slavable

  def test1
    Bar.create
  end

  def test2
    Foo.create
  end

  switch :test1, :test2, to: :other
end

describe 'switch' do
  context 'on instance methods' do
    context 'when multiple methods defined' do
      let(:example) { MultipleMethods.new }
      it 'switches some_method to other connection' do
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
