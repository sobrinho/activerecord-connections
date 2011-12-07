require 'active_support'

module ActiveRecord
  module Connections
    autoload :ConnectionProxy, 'active_record/connections/connection_proxy'

    # Using on ApplicationController:
    #
    #   class ApplicationController < ActionController::Base
    #     before_filter :handle_customer
    #
    #     protected
    #
    #     def handle_customer(&block)
    #       customer = Customer.find_by_domain!(request.domain)
    #       ActiveRecord::Base.using_connection(customer.id, customer.connection_spec, &block)
    #     end
    #   end
    #
    # Using directly on models:
    #
    #   customer = Customer.first
    #
    #   ActiveRecord::Base.using_connection(customer.id, customer.connection_spec) do
    #     User.count # => 3
    #   end
    #
    def using_connection(connection_name, connection_spec)
      self.proxy_connection = ConnectionProxy.new(connection_name, connection_spec)

      def self.connection_pool
        connection_handler.retrieve_connection_pool(proxy_connection)
      end

      def self.retrieve_connection
        connection_handler.retrieve_connection(proxy_connection)
      end

      yield
    ensure
      self.proxy_connection = nil

      def self.connection_pool
        connection_handler.retrieve_connection_pool(self)
      end

      def self.retrieve_connection
        connection_handler.retrieve_connection(self)
      end
    end

    def proxy_connection
      Thread.current["ActiveRecord::Connections.proxy_connection"]
    end

    def proxy_connection=(proxy_connection)
      Thread.current["ActiveRecord::Connections.proxy_connection"] = proxy_connection
    end
  end
end

ActiveSupport.on_load(:active_record) do
  extend ActiveRecord::Connections
end
