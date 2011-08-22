#
# This class is used to automatically generate small abstract ActiveRecord classes
# that would then be used as a source of database connections for ActiveRecord::Connections.
# This way we do not need to re-implement all the connection establishing code
# that ActiveRecord already has and we make our code less dependant on Rails versions.
#
module ActiveRecord
  module Connections
    class ConnectionFactory
      cattr_accessor :connection_classes
      self.connection_classes = {}

      # Establishes connection or return an existing one from cache
      def self.establish_connection(connection_name, connection_spec)
        connection_classes[connection_name] ||= make_connection_klass(connection_name, connection_spec)
      end

      protected

      # Generate an abstract AR class with specified connection established
      def self.make_connection_klass(connection_name, connection_spec)
        # Generate class
        klass = generate_connection_klass(connection_name)

        # Establish connection
        klass.establish_connection(connection_spec)

        # Return the class
        return klass
      end

      def self.generate_connection_klass(connection_name)
        class_eval <<-RUBY
          class AbstractConnection#{connection_name} < ActiveRecord::Base
            self.abstract_class = true

            self
          end
        RUBY
      end
    end
  end
end
