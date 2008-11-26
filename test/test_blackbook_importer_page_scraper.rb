require File.join( File.dirname(__FILE__), '..', 'lib', 'blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'

class TestBlackbookImporterPageScraper < Test::Unit::TestCase

  include TestHelper

  def setup
    @scraper = Blackbook::Importer::PageScraper.new
  end

  def test_mechanize_patch_to_absolute_uri
    @scraper.create_agent
    response = {'content-type' => 'text/html'}
    page = WWW::Mechanize::Page.new(uri=nil, response, '<html></html>', code=nil, mech=nil)
    url = "http://localhost/?arg=val&jank=AAA%3D"
    assert_equal URI.parse(url), @scraper.agent.send(:to_absolute_uri, url)
    # pattern of odd URL created by javascript validator in AOL webmail login
    url = "http://localhost/?arg=val&jank=AAA%3D%3D"
    assert_equal URI.parse(url), @scraper.agent.send(:to_absolute_uri, url)
  end

  def test_create_agent
    agent = nil
    assert_nothing_raised do
      agent = @scraper.create_agent
    end
    assert_equal agent, @scraper.agent
    assert_equal true, agent.is_a?(WWW::Mechanize)
    assert_equal "Mozilla/4.0 (compatible; Blackbook #{Blackbook::VERSION})", agent.user_agent
    assert_equal false, agent.keep_alive
  end

  def test_strip_html
    assert_equal '', @scraper.strip_html('<foo></foo>')
    assert_equal 'bar', @scraper.strip_html('<foo>bar</foo>')
    assert_equal 'bar', @scraper.strip_html('bar</foo>')
    assert_equal 'bar', @scraper.strip_html('<foo>bar')
  end

  def test_fetch_contacts!
    @scraper.expects(:create_agent).once
    @scraper.expects(:prepare).once
    @scraper.expects(:scrape_contacts).once
    assert_nothing_raised do
      agent = @scraper.fetch_contacts!
    end
  end
end
