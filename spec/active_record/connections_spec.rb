require 'bundler/setup'
require 'rspec'
require 'active_record'
require 'active_record/connections'
require 'support/customer'
require 'support/contact'

describe ActiveRecord::Connections do
  let :migrations_path do
    File.expand_path('../../db/migrate', __FILE__)
  end

  before do
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')

    ActiveRecord::Migration.verbose = false
    ActiveRecord::Migrator.migrate(migrations_path)

    @customer_1 = Customer.create!(:name => 'Customer 1')
    @customer_2 = Customer.create!(:name => 'Customer 2')
    @customer_3 = Customer.create!(:name => 'Customer 3')

    Customer.each do
      ActiveRecord::Migrator.migrate(migrations_path)
    end

    Customer.each do |customer|
      Contact.create!(:name => "Gabriel Sobrinho")
    end
  end

  after do
    Customer.each do
      Contact.destroy_all
    end

    Customer.destroy_all
  end

  it 'use proxy connection for count' do
    Customer.each do |customer|
      Contact.count.should eq 1
    end
  end

  it 'use proxy connection for create' do
    Customer.each do |customer|
      Contact.first.should be
    end
  end

  it 'use proxy connection for update' do
    Customer.each do |customer|
      Contact.update_all(:name => customer.name)
    end

    Customer.each do |customer|
      Contact.first.name.should eq customer.name
    end
  end

  it 'use proxy connection for destroy' do
    Customer.each do
      Contact.destroy_all
    end

    Customer.each do |customer|
      Contact.count.should eq 0
    end
  end

  it 'allows nested proxy connections' do
    @customer_1.using_connection do
      @customer_2.using_connection do
        @customer_3.using_connection do
          Contact.update_all(:name => @customer_3.name)
        end

        Contact.update_all(:name => @customer_2.name)
      end

      Contact.update_all(:name => @customer_1.name)
    end

    Customer.each do |customer|
      Contact.first.name.should eq customer.name
    end
  end

  it 'do not propagate proxy connection between threads (thread-safe)' do
    Thread.new do
      ActiveRecord::Base.proxy_connection = 'proxy connection from another thread'
    end.join

    ActiveRecord::Base.proxy_connection.should be_nil
  end
end
