require 'byebug'
module CheckedAttributes
  class InvalidAttributeError < ::StandardError; end
  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end
  module ClassMethods
    def attr_checked(col, &block)
      return attr_accessor_with_validations(col, block) if block_given?
      # attr_accessor col
    end
    def attr_accessor_with_validations(col, block)
      attr_reader col
      define_method "#{col}=" do |val|
        raise InvalidAttributeError unless block.call(val)
        instance_variable_set("@#{col}", val)
      end
    end
  end
end
class Person
  include CheckedAttributes

  attr_checked :age do |v|
    v >= 18
  end
end

RSpec.describe Person do
  let(:person) { Person.new }
  describe '.attr_checked' do
    context 'when valid' do
      subject { person.age = 20 }
      it{ expect(subject).to eq 20 }
      it{ expect{subject}.not_to raise_error }
    end
    context 'when invalid' do
      subject { person.age = 11 }
      it{ expect{subject}.to raise_error(CheckedAttributes::InvalidAttributeError) }
    end
  end
end
