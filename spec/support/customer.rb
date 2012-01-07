class Customer < ActiveRecord::Base
  def self.each(&block)
    find_each do |customer|
      customer.using_connection(&block)
    end
  end

  def using_connection
    ActiveRecord::Base.using_connection(id, database_spec) do
      yield self
    end
  end

  def database_spec
    { :adapter => 'sqlite3', :database => ':memory:' }
  end
end
