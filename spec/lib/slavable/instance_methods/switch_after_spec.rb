require 'spec_helper'

class SwitchAfter
  extend Slavable

  def some_method
    Bar.create
  end
  switch :some_method, to: :other
end

describe 'switch' do
  context 'on instance methods' do
    context 'when switch after method definition' do
      let(:example) { SwitchAfter.new }
      it 'switches some_method to other connection' do
        example.some_method

        expect(Bar.count).to eq 0
        expect(Bar.on(:other).count).to eq 1
      end
    end
  end
end
