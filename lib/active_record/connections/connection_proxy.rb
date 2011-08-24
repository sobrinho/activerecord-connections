require 'active_support/basic_object'

module ActiveRecord
  module Connections
    class ConnectionProxy < ActiveSupport::BasicObject
      def initialize(connection_name, connection_spec)
        @connection_name, @connection_spec = connection_name, connection_spec
      end

      def respond_to?(method_name, include_private = false)
        connection.respond_to?(method_name, include_private)
      end

      def method_missing(method_name, *arguments, &block)
        connection.send(method_name, *arguments, &block)
      end

      private

      def connection
        @connection ||= retrieve_connection_klass rescue fabricate_connection_klass
      end

      def retrieve_connection_klass
        "ActiveRecord::Connections::AbstractConnection#{@connection_name}".constantize
      end

      def fabricate_connection_klass
        ::ActiveRecord::Connections.class_eval <<-RUBY
          class AbstractConnection#{@connection_name} < ActiveRecord::Base
            self.abstract_class = true
            self.establish_connection(#{@connection_spec.inspect})

            self
          end
        RUBY
      end
    end
  end
end
