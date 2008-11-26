require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'

class TestBlackbook < Test::Unit::TestCase

  include TestHelper

  def test_class_get
    Blackbook.any_instance.expects(:get)
    Blackbook.get
  end

  def test_class_instance
    assert Blackbook.instance.is_a?(Blackbook)
  end

  def test_class_register
    Blackbook.register(:base, Blackbook::Exporter::Base)
    assert Blackbook.instance.exporters[:base].is_a?(Blackbook::Exporter::Base)
    
    Blackbook.register(:base, Blackbook::Importer::Base)
    assert Blackbook.instance.importers[:base].is_a?(Blackbook::Importer::Base)
  end

  def test_class_register_raises_on_bad_register
    assert_raises(ArgumentError) do
      Blackbook.register(:bad, String)
    end
  end

  def test_export
    importer = Blackbook::Importer::Base.new
    exporter = Blackbook::Exporter::Base.new
    importer.expects(:import)
    exporter.expects(:export)
    Blackbook.instance.export( importer, exporter, {} )
  end

  def test_find_importer
    base = Blackbook::Importer::Base.new
    base.stubs(:=~).returns(true)
    Blackbook.any_instance.stubs(:importers).returns({:basic => base})
    assert_equal base, Blackbook.instance.find_importer(:as => :basic)
    
    base.stubs(:=~).returns(false)
    assert_nil Blackbook.instance.find_importer(:as => :basic)
  end

  def test_get
    cards = Blackbook.instance.get( :csv, :file => fixture_file('gmail.csv') )
    assert_equal 2, cards.size
    assert cards.detect{|card| card[:name] == "Joe User"}
    assert cards.detect{|card| card[:name] == "Some Guy"}
    assert cards.detect{|card| card[:email] == "joeuser@example.com"}
    assert cards.detect{|card| card[:email] == "someguy@example.com"}
  end
  
end
