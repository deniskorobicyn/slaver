require 'spec_helper'

class SwitchBefore
  extend Slavable

  switch :some_method, to: :other

  def some_method
    Bar.create
  end
end

describe 'switch' do
  context 'on instance methods' do
    context 'when switch before method definition' do
      let(:example) { SwitchBefore.new }
      it 'switches test to other connection' do
        example.some_method

        expect(Bar.count).to eq 0
        expect(Bar.on(:other).count).to eq 1
      end
    end
  end
end
