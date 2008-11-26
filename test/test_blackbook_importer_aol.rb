require File.join( File.dirname(__FILE__), '../lib/blackbook.rb' )
require File.join( File.dirname(__FILE__), 'test_helper.rb' )
require 'test/unit'
require 'mocha'
require 'mechanize'


class TestBlackbookImporterAol < Test::Unit::TestCase

  include TestHelper

  def setup
    @importer = Blackbook::Importer::Aol.new
    @importer.options = {:username => 'user@aol.com', :password => 'password'}
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
    assert_equal true, @importer =~ {:username => 'joe@aol.com'}
    assert_equal true, @importer =~ {:username => 'joe@aim.com'}
    assert_equal true, @importer =~ {:username => 'JOE@AOL.COM'}
    assert_equal true, @importer =~ {:username => 'JOE@AIM.COM'}
  end

  def test_login
    response = {'content-type' => 'text/html'}

    body = load_fixture('aol_login_response_stage_2.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://webmail.aol.com/').once.returns(page)

    body = load_fixture('aol_login_response_stage_3.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    body = load_fixture('aol_login_response_stage_4.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with(
      'http://webmail.aol.com/_cqr/LoginSuccess.aspx?sitedomain=sns.webmail.aol.com&authLev=2&siteState=ver%3A2%7Cac%3AWS%7Cat%3ASNS%7Cld%3Awebmail.aol.com%7Cuv%3AAOL%7Clc%3Aen-us&lang=en&locale=us&uitype=std&mcAuth=%2Fblackbookauthtest%3D%3D'
    ).once.returns(page)

    body = load_fixture('aol_login_response_stage_5.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('/31361/aim/en-us/Lite/Today.aspx').once.returns(page)

    assert_nothing_raised do
      assert @importer.login
    end
  end

  def test_login_bad_credentials
    response = {'content-type' => 'text/html'}

    body = load_fixture('aol_login_response_stage_2.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with('http://webmail.aol.com/').once.returns(page)

    body = load_fixture('aol_bad_login_response_stage_3.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:submit).once.returns(page)

    assert_raises(Blackbook::BadCredentialsError) do
      @importer.login
    end
  end

  def test_scrape_contacts_raises_badcredentialerror_when_not_logged_in
    @importer.agent.expects(:cookies).once.returns([])
    assert_raises(Blackbook::BadCredentialsError) do
      @importer.scrape_contacts
    end
  end

  def test_scrape_contacts
    cookie = WWW::Mechanize::Cookie.new('Auth',
      'ver:7&uas:user%2cuser%2caim.com%2c0%2c0%2c0%2cAIM%2cen-us%2c2%2c633308135438559961%2c0%2c1%3b&un:user&at:SNS&sn:user&wim:djEgMVM%253D-Qg0R3W9DSOpFNfKRog8SxBigVbPg%252BDTtGsaBctTczECZruX82XONmIMGYsY%253D&sty:0&ud:aim.com&uid:blackbookuid&ss:633308135438559961&sst:1195234657&la:633308135438559961&lrid:25156&act:M&br:0&mbt:T&uv:AIM&lc:en-us&acd:315532800&pix:0&prmc:135925&relm:im&mah:&sah:&snh:ZDdhMTQ5YjlmZjQ5NTE5ZTFkYWI5OTU0ZDU1NWNlYTM%3d&miu:True&sit:sns.webmail.aol.com&ckd:.webmail.aol.com&ckp:%2f&ha:ABrytqN65h7Czwu0%2bDXlQGuc%2fQY%3d&')
    cookie.domain = 'localhost'
    @importer.agent.expects(:cookies).once.returns([cookie])

    response = {'content-type' => 'text/html'}
    body = load_fixture('aol_application_page.html').join
    uri = URI.parse('http://webmail.aol.com/34865/aim/en-us/Lite/Today.aspx')
    page = WWW::Mechanize::Page.new(uri, response, body, code=nil, mech=nil)
    @importer.agent.expects(:current_page).times(2).returns(page)

    response = {'content-type' => 'text/html'}
    body = load_fixture('aol_contacts.html').join
    page = WWW::Mechanize::Page.new(uri=nil, response, body, code=nil, mech=nil)
    @importer.agent.expects(:get).with(
      'http://webmail.aol.com/34865/aim/en-us/Lite/addresslist-print.aspx?command=all&sort=FirstLastNick&sortDir=Ascending&nameFormat=FirstLastNick&user=ULKLrUelQ2'
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
