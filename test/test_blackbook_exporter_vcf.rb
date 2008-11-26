require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'

class TestBlackbookExporterVcf < Test::Unit::TestCase

  include TestHelper

  def setup
    @card = Blackbook::Exporter::Vcf::Vcard.new(
             {'first' => 'joe', 'last' => 'user', 
              'email' => 'joe.user@example.com'})
    @exporter = Blackbook::Exporter::Vcf.new
  end

  def test_vcard
    assert_equal 'joe', @card.first
    assert_equal 'user', @card.last
    assert_equal 'joe.user@example.com', @card.email
  end

  def test_vcard_to_s
    card = %q!BEGIN:VCARD
N:user;joe
EMAIL:joe.user@example.com
END:VCARD
!
    assert_equal card, @card.to_s
    assert_equal 'user', @card.last
    assert_equal 'joe.user@example.com', @card.email
  end

  def test_export
    contacts = [{ :name => 'Test', :email => 'test@example.com' }]
    expected = <<VCF
BEGIN:VCARD
N:;Test
EMAIL:test@example.com
END:VCARD
VCF
    exported = @exporter.export(contacts)
    assert_equal 1, exported.size
    assert_equal expected, exported.first.to_s
  end

  def test_export_when_contacts_blank
    assert_nil @exporter.export()
    assert_nil @exporter.export([])
  end

end
