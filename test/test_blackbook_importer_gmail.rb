require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'

class TestBlackbookImporterGmail < Test::Unit::TestCase

  include TestHelper

  def setup
    @importer = Blackbook::Importer::Gmail.new
    @importer.options = {:username => 'user@gmail.com', :password => 'password'}
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
    assert_equal true, @importer =~ {:username => 'joe@gmail.com'}
    assert_equal true, @importer =~ {:username => 'JOE@GMAIL.COM'}
  end

  def test_bad_login
    response = {'content-type' => 'text/html'}

    body = load_fixture('gmail_login_response_stage_1.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://mail.google.com/mail/').once.returns(page)

    body = load_fixture('gmail_bad_login_response_stage_2.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    assert_raises(Blackbook::BadCredentialsError) do
      @importer.login
    end
  end

  def test_login
    response = {'content-type' => 'text/html'}

    body = load_fixture('gmail_login_response_stage_1.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://mail.google.com/mail/').once.returns(page)

    body = load_fixture('gmail_login_response_stage_2.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    body = load_fixture('gmail_login_response_stage_3.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://mail.google.com/mail/?ui=html&zy=l'
    ).once.returns(page)

    assert_nothing_raised do
      assert @importer.login
    end
  end

  def test_login_alternative_uri
    response = {'content-type' => 'text/html'}

    body = load_fixture('gmail_login_response_stage_1.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://mail.google.com/mail/').once.returns(page)

    body = load_fixture('gmail_login_response_stage_2a.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    body = load_fixture('gmail_login_response_stage_3.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://mail.google.com/mail/?ui=html&zy=l'
    ).once.returns(page)

    assert_nothing_raised do
      assert @importer.login
    end
  end

  def test_scrape_contacts_raises_badcredentialerror_when_not_logged_in
    @importer.agent.expects(:cookies).once.returns([])
    assert_raises(Blackbook::BadCredentialsError) do
      @importer.scrape_contacts
    end
  end

  def test_scrape_contacts
    cookie = WWW::Mechanize::Cookie.new('GAUSR', 'mail:user@gmail.com')
    @importer.agent.expects(:cookies).once.returns([cookie])

    response = {'content-type' => 'text/html'}
    body = load_fixture('gmail_contacts.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with(
      'http://mail.google.com/mail/h/?v=cl&pnl=a'
    ).once.returns(page)

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
