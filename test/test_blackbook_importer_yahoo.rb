require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'

class TestBlackbookImporterYahoo < Test::Unit::TestCase

  include TestHelper

  def setup
    @importer = Blackbook::Importer::Yahoo.new
    @importer.options = {:username => 'user@yahoo.com', :password => 'password'}
    @importer.create_agent
  end

  def test_prepare
    @importer.expects(:login).once
    @importer.prepare
  end

  def test_importer_match
    assert_equal false, @importer =~ nil
    assert_equal false, @importer =~ {}
    assert_equal false, @importer =~ {'username' => 'joe@example.com'}
    assert_equal false, @importer =~ {:username => 'joe@example.com'}
    assert_equal false, @importer =~ {:username => 'joe'}
    assert_equal true, @importer =~ {:username => 'joe@yahoo.com'}
    assert_equal true, @importer =~ {:username => 'JOE@YAHOO.COM'}
  end

  def test_login
    response = {'content-type' => 'text/html'}

    body = load_fixture('yahoo_login_response_stage_1.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('https://login.yahoo.com/config/login_verify2?').once.returns(page)

    body = load_fixture('yahoo_login_response_stage_2.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    assert_nothing_raised do
      assert @importer.login
    end
  end

  def test_bad_login
    response = {'content-type' => 'text/html'}

    body = load_fixture('yahoo_login_response_stage_1.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('https://login.yahoo.com/config/login_verify2?').once.returns(page)

    body = load_fixture('yahoo_bad_login_response_stage_2.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    assert_raises(Blackbook::BadCredentialsError) do
      @importer.login
    end
  end

  def test_scrape_contacts_raises_badcredentialerror_when_not_logged_in
    response = {'content-type' => 'text/html'}
    body = load_fixture('yahoo_contacts_not_logged_in.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://address.yahoo.com/?1=&VPC=import_export'
      ).once.returns(page)

    assert_raises(Blackbook::BadCredentialsError) do
      @importer.scrape_contacts
    end
  end

  def test_scrape_contacts
    response = {'content-type' => 'text/html'}
    body = load_fixture('yahoo_contacts_stage_1.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://address.yahoo.com/?1=&VPC=import_export'
      ).once.returns(page)

    response = {'content-type' => 'text/csv; charset=UTF-8'}
    body = load_fixture('yahoo_contacts.csv').join
    page = WWW::Mechanize::File.new(uri=nil, response, body, code=nil)
    @importer.agent.expects(:submit).once.returns(page)

    assert_nothing_raised do
      contacts = @importer.scrape_contacts
      assert_equal 2, contacts.size
      assert contacts.detect{|c| c[:email] == 'joe.user@example.com'}
      assert contacts.detect{|c| c[:name] == 'Joe User'}
      assert contacts.detect{|c| c[:email] == 'jane.user@example.com'}
      assert contacts.detect{|c| c[:name] == 'Jane User'}
    end
  end

end
