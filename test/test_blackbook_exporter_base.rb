require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'

class TestBlackbookExporterBase < Test::Unit::TestCase

  include TestHelper

  def test_export
    exporter = Blackbook::Exporter::Base.new
    contacts = [{ :name => 'Test', :email => 'test@domain.com' }]
    assert_equal contacts, exporter.export(contacts)
  end

end
