require 'spec_helper'

class UndefinedMethod
  extend Slavable

  switch :unexisting_method, to: :other
end

describe 'switch' do
  let!(:example) { UndefinedMethod.new }
  it 'do nothing' do
    expect(example.respond_to?(:unexisting_method)).to be_falsey
  end
end
