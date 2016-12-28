# Public:
#   It'll add `switch` method to your class which helps you to switch connection for some method in your class.
#   Any query that your method executes will use connection defined in `to` option
#
# Examples:
#   class SomeModel
#     extend Slavadle
#
#     switch :some_method, to: :other
#
#     def some_method
#       where(smth: 'name')
#     end
#   end
#
#   Class method switch:
#
#   class SomeModel
#     class << self
#       extend Slavadle
#
#       switch :scope, to: :other
#     end
#
#     def self.scope
#       where(smth: 'name')
#     end
#   end
#
# For more please visit spec/lib/slavable/ folder.
#
# Implementation details:
#   For each method we define new one which executes old one in Slaver::within block.
#
#   If method already defined, it'll alias it as alias_method_chain will do.
#   If not, it'll use method_added and singleton_method_added from Ruby Dark Magic Book™ to add aliases when its defined
#
module Slavable
  def self.extended(base)
    if base.send :singleton_class?
      base.send :include, SingletonMethods
    else
      base.extend InstanceMethods
    end
  end

  module PrivateMethods
    def connection_method_name(method)
      aliased_method, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
      with_name = "#{aliased_method}_with_connection#{punctuation}"
      without_name = "#{aliased_method}_without_connection#{punctuation}"

      [with_name, without_name]
    end
  end
  include PrivateMethods

  module InstanceMethods
    include PrivateMethods

    def method_added(method)
      return unless defined?(@switched_methods)
      return unless @switched_methods.include?(method)

      with_name, without_name = connection_method_name(method)

      @switched_methods.delete(method)
      alias_method without_name, method
      alias_method method, with_name
    end
  end

  module SingletonMethods
    include PrivateMethods

    def singleton_method_added(method)
      switched_methods = singleton_class.instance_variable_get(:@switched_methods)

      return unless switched_methods
      return unless switched_methods.include?(method)

      with_name, without_name = connection_method_name(method)

      switched_methods.delete(method)
      singleton_class.instance_variable_set(:@switched_methods, switched_methods)

      singleton_class.send :alias_method, without_name, method
      singleton_class.send :alias_method, method, with_name
    end
  end

  def switch(*method_names)
    options = method_names.pop

    unless options.is_a?(Hash)
      raise ArgumentError, 'Unable to detect "to" option, usage: "switch :method, :other, ..., to: :connection_name"'
    end

    method_names.each do |method|
      with_name, without_name = connection_method_name(method)
      connection = options.with_indifferent_access.fetch(:to)

      class_eval <<-eoruby, __FILE__, __LINE__ + 1
        def #{with_name}(*args, &block)
          ::ActiveRecord::Base.within(:#{connection}) { send(:#{without_name}, *args, &block) }
        end
      eoruby

      if singleton_class?
        begin
          alias_method without_name, method
          alias_method method, with_name
        rescue NameError
          @switched_methods ||= []
          @switched_methods << method
        end
      elsif instance_methods.include?(method) || methods.include?(method)
        alias_method without_name, method
        alias_method method, with_name
      else
        @switched_methods ||= []
        @switched_methods << method
      end
    end
  end
end
