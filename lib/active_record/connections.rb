require 'active_support/concern'

module ActiveRecord
  module Connections
    autoload :ConnectionFactory, 'active_record/connections/connection_factory'
    autoload :ConnectionProxy, 'active_record/connections/connection_proxy'

    extend ActiveSupport::Concern

    included do
      cattr_accessor :proxy_connection
    end

    module ClassMethods
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
        self.proxy_connection = ActiveRecord::Connections::ConnectionFactory.connect(connection_name, connection_spec)

        def self.connection
          proxy_connection
        end

        yield
      ensure
        self.proxy_connection = nil

        def self.connection
          retrieve_connection
        end
      end
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include ActiveRecord::Connections
end