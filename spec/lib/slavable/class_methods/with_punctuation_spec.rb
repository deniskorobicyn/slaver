require 'spec_helper'

class ClassWithPunctuation
  def self.test=(name)
    Foo.create(name: name)
  end

  def self.test?(name)
    Foo.where(name: name).exists?
  end

  class << self
    extend Slavable
    switch :test?, :test=, to: :other
  end
end

describe 'switch' do
  context 'on class methods' do
    context 'when switch methods with punctuation' do
      let(:example) { ClassWithPunctuation }

      it 'switches test= and test? to other connection' do
        example.test = 'some_name'

        expect(Foo.on(:other).count).to eq 1
        expect(example.test?('some_name')).to be_truthy
      end
    end
  end
end
