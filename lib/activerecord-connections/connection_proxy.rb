# Simple proxy that sends all method calls to a real database connection
module ActiveRecord
  module Connections
    class ConnectionProxy < ActiveSupport::BasicObject
      def initialize(klass)
        @klass = klass
      end

      def method_missing(method, *arguments, &block)
        @klass.retrieve_connection.send(method, *arguments, &block)
      end

      def respond_to?(method, include_private = false)
        @klass.retrieve_connection.respond_to?(method, include_private)
      end
    end
  end
end
