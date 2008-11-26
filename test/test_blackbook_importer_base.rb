require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'

class TestBlackbookImporterBase < Test::Unit::TestCase

  include TestHelper

  def test_service_name
    assert_equal "Base", Blackbook::Importer::Base.new.service_name
  end

  def test_import
    importer = Blackbook::Importer::Base.new
    importer.expects(:fetch_contacts!)
    options = {:foo => 'bar'}
    assert_nothing_raised do
      importer.import(options)
    end
    assert_equal options, importer.options
  end

end
