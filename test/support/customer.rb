class Customer < ActiveRecord::Base
  def using_connection
    ActiveRecord::Base.using_connection(id, database_spec) do
      yield self
    end
  end

  def database_spec
    { :adapter => 'sqlite3', :database => ':memory:' }
  end
end
