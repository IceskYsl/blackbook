require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'
require 'mechanize'

class TestBlackbookImporterHotmail < Test::Unit::TestCase

  include TestHelper

  
  def setup
    @importer = Blackbook::Importer::Hotmail.new
    @importer.options = {:username => 'user@hotmail.com', :password => 'password'}
    @importer.create_agent
  end

  def test_bad_login
    response = {'content-type' => 'text/html'}

    body = load_fixture('hotmail_login_response_stage_1.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://login.live.com/login.srf?id=2'
      ).once.returns(page)

    body = load_fixture('hotmail_bad_login_response_stage_2.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    assert_raises(Blackbook::BadCredentialsError) do
      @importer.login
    end

  end

  def test_login
    response = {'content-type' => 'text/html'}

    body = load_fixture('hotmail_login_response_stage_1.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://login.live.com/login.srf?id=2'
      ).once.returns(page)

    body = load_fixture('hotmail_login_response_stage_2.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    body = load_fixture('hotmail_login_response_stage_3.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with(
    'http://www.hotmail.msn.com/cgi-bin/sbox?t=9m9!oYK!qAKigHv8qDw1X1CMCqcbK10gIMWFQjyEK5dofUz!Aneq2zVs58p30sL*Vn8LAwVDD7952o!s1iny8uLHnZxso8YLLoQo4Z3CxhDx11tpPojydwUvwNF9zLFas7&p=9ZiSOOa!3CzsA5AbkqScGrB6w0zuXf!S*UaqQfk0fTM54toklVx51mUYcS3O8JAxjQmsQiwdEBIueipsTADcMs!2RRit547E5MtOMhA6NdiUNkoRvaGsSXK*j1iKAm7Z5jpdKpvW8oSv5yNpN5mWoULuD6lUEqC7i0KHR22e3NJ95C8uGbIGfgxkCjluo7Ye0eJcGraNIAbG0$&lc=1033&id=2'
      ).once.returns(page)

    assert_nothing_raised do
      @importer.login
    end
  end

  def test_scrape_contacts_not_logged_in
    @importer.agent.expects(:cookies).once.returns([])
    assert_raises(Blackbook::BadCredentialsError) do
      @importer.scrape_contacts
    end
  end

  def test_scrape_contacts
    cookie = WWW::Mechanize::Cookie.new('MSPPre', 'user@hotmail.com')
    cookie.domain = 'localhost'
    @importer.agent.expects(:cookies).once.returns([cookie])

    response = {'content-type' => 'text/html'}
    body = load_fixture('hotmail_contacts.html').join
    uri = URI.parse('http://by135w.bay135.mail.live.com/mail/')
    page = WWW::Mechanize::Page.new(uri, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('PrintShell.aspx?type=contact').once.returns(page)

    assert_nothing_raised do
      contacts = @importer.scrape_contacts
      assert_equal 2, contacts.size
      assert contacts.detect{|c| c[:email] == 'joe.user@example.com'}
      assert contacts.detect{|c| c[:name] == 'Joe User'}
      assert contacts.detect{|c| c[:email] == 'jane.user@example.com'}
      assert contacts.detect{|c| c[:name] == 'Jane User'}
    end
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

    domains = ["compaq.net",
               "hotmail.co.jp",
               "hotmail.co.uk",
               "hotmail.com",
               "hotmail.de",
               "hotmail.fr",
               "hotmail.it",
               "messengeruser.com",
               "msn.com",
               "passport.com",
               "webtv.net"]
    domains.each do |domain|
      assert_equal true, @importer =~ {:username => "joe@#{domain}"}
      assert_equal true, @importer =~ {:username => "joe@#{domain}".upcase}
    end
  end


  def test_login_url
    assert_equal "https://login.live.com/ppsecure/post.srf", @importer.login_url
    @importer.options = {:username => 'user@msn.com', :password => 'password'}
    assert_equal "https://msnia.login.live.com/ppsecure/post.srf", @importer.login_url
  end

  def test_current_host
    response = {'content-type' => 'text/html'}
    page = WWW::Mechanize::Page.new(URI.parse('http://localhost/'), response, '<html></html>', code=nil, mech=nil)

    importer = Blackbook::Importer::Hotmail.new
    assert_nil importer.current_host
    importer.create_agent
    assert_nil importer.current_host
    importer.agent.expects(:current_page).times(2).returns(page)
    assert_equal 'http://localhost', importer.current_host
  end

  def test_username_domain(username = nil)
    importer = Blackbook::Importer::Hotmail.new
    assert_nil importer.username_domain
    assert_equal 'example.com', importer.username_domain('user@example.com')
    assert_equal 'example.com', @importer.username_domain('user@example.com')
    assert_equal 'hotmail.com', @importer.username_domain
  end

end
