require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'tempfile'
require 'test/unit'
require 'mocha'

class TestBlackbookImporterCsv < Test::Unit::TestCase

  include TestHelper

  def setup
    @importer = Blackbook::Importer::Csv.new
  end

  def test_importer_match
    csv = Tempfile.new('test.csv')
    assert_equal false, @importer =~ nil
    assert_equal false, @importer =~ {}
    assert_equal false, @importer =~ {:file => nil}
    assert_equal true, @importer =~ {:file => csv}
  end

  def test_to_hash
    cols = [:name, :email, :misc]
    assert_equal({:name => 'joe', :email => 'joe@example.com', :misc => ''}, 
      @importer.to_hash(cols,['joe', 'joe@example.com']))
    assert_equal({:name => 'joe', :email => 'joe@example.com', :misc => 'foo'}, 
      @importer.to_hash(cols,['joe', 'joe@example.com', 'foo']))
    assert_equal({:name => 'joe', :email => 'joe@example.com', :misc => 'foo,bar'}, 
      @importer.to_hash(cols,['joe', 'joe@example.com', 'foo', 'bar']))
  end

  def test_to_columns
    assert_equal [:name,:email,:misc], @importer.to_columns('name,email,misc')
    assert_equal [:name,:email,:misc], @importer.to_columns('Name,email,misc')
    assert_equal [:name,:email,:misc], @importer.to_columns('Name,Email,misc')
    assert_equal [:name,:email,:misc], @importer.to_columns('Name,E-mail,misc')
  end

  def test_fetch_contacts_with_no_column_names
    file = mock(:path => '/tmp/test.csv')
    options = {:file => file}
    @importer.instance_variable_set(:@options, options)
    IO.expects(:readlines).with('/tmp/test.csv').once.returns(['joe,joe@example.com','fred,fred@example.com'])
    expected = [{:name => 'joe', :email => 'joe@example.com', :misc => ''},
                {:name => 'fred', :email => 'fred@example.com', :misc => ''}]
    assert_equal expected, @importer.fetch_contacts!
  end

  def test_fetch_contacts_with_column_names
    file = mock(:path => '/tmp/test.csv')
    options = {:file => file}
    @importer.instance_variable_set(:@options, options)
    IO.expects(:readlines).with('/tmp/test.csv').once.returns(['name,email,misc','joe,joe@example.com','fred,fred@example.com'])
    expected = [{:name => 'joe', :email => 'joe@example.com', :misc => ''},
                {:name => 'fred', :email => 'fred@example.com', :misc => ''}]
    assert_equal expected, @importer.fetch_contacts!
  end

end
