require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'

class TestBlackbookExporterXml < Test::Unit::TestCase

  include TestHelper

  def test_export
    exporter = Blackbook::Exporter::Xml.new
    contacts = [{ :name => 'Test', :email => 'test@domain.com' }]
    assert_equal "<?xml version='1.0'?><contacts><contact><name>Test</name><email>test@domain.com</email></contact></contacts>", exporter.export(contacts)
  end

end
