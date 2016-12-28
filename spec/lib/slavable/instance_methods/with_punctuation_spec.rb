require 'spec_helper'

class WithPunctuation
  extend Slavable

  def test=(name)
    Foo.create(name: name)
  end

  def test?(name)
    Foo.where(name: name).exists?
  end
  switch :test?, :test=, to: :other
end

describe 'switch' do
  context 'on instance methods' do
    context 'when switch methods with punctuation' do
      let(:example) { WithPunctuation.new }

      it 'switches test= and test? to other connection' do
        example.test = 'some_name'

        expect(Foo.on(:other).count).to eq 1
        expect(example.test?('some_name')).to be_truthy
      end
    end
  end
end
