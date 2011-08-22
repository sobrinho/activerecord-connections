require 'test_helper'
require 'active_record'
require 'active_record/connections'
require 'support/customer'
require 'support/contact'

class ActiveRecord::ConnectionsTest < MiniTest::Unit::TestCase
  MIGRATIONS_PATH = File.expand_path('../../db/migrate', __FILE__)

  def setup
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate(MIGRATIONS_PATH)

    @customer_1 = Customer.create!(:name => 'Customer 1')
    @customer_2 = Customer.create!(:name => 'Customer 2')
    @customer_3 = Customer.create!(:name => 'Customer 3')

    self.each_customer do
      ActiveRecord::Migrator.migrate(MIGRATIONS_PATH)
    end

    self.each_customer do |customer|
      Contact.create!(:name => "Gabriel Sobrinho")
    end
  end

  def teardown
    self.each_customer do
      Contact.destroy_all
    end

    Customer.destroy_all
  end

  def test_count
    self.each_customer do |customer|
      assert_equal 1, Contact.count, "#{customer.name} should have one contact"
    end
  end

  def test_create
    self.each_customer do |customer|
      assert Contact.first, "#{customer.name} should have Gabriel Sobrinho as contact"
    end
  end

  def test_update
    self.each_customer do |customer|
      Contact.update_all(:name => customer.name)
    end

    self.each_customer do |customer|
      assert_equal customer.name, Contact.first.name, "#{customer.name} should have itself as contact"
    end
  end

  def test_destroy
    self.each_customer do
      Contact.destroy_all
    end

    self.each_customer do |customer|
      assert_equal 0, Contact.count, "#{customer.name} should have no contacts"
    end
  end

  protected

  def each_customer(&block)
    Customer.find_each do |customer|
      customer.using_connection(&block)
    end
  end
end
