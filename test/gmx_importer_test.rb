require File.dirname(__FILE__) + '/../test_helper.rb'

context "The GMX importer" do

  setup do
    @username, @password = BlackbookExtensions::TestHelper::Credentials.new(:gmx).get

    @importer = Blackbook::Importer::GMX.new
    @importer.create_agent
  end

  specify "should match emails" do
    @importer.=~(nil).should.not.be
    @importer.=~({}).should.not.be
    @importer.=~({ 'username' => "john@foo.com" }).should.not.be
    @importer.=~({ :username => "john@foo.com" }).should.not.be
    @importer.=~({ :username => "john" }).should.not.be
    @importer.=~({ :username => "john@gmx.de" }).should.be
    @importer.=~({ :username => "JOHN@GMX.DE" }).should.be
  end

  specify "should be able to login with correct credentials" do
    should.not.raise Exception do
      login(@username, @password)
    end
  end

  specify "should raise BadCredentialsError on login with wrong credentials" do
    should.raise Blackbook::BadCredentialsError do
      login
    end
  end

  specify "should raise BadCredentialsError on login with correct username and wrong password" do
    should.raise Blackbook::BadCredentialsError do
      login(@username)
    end
  end

  specify "should able to get contacts" do
    login(@username, @password)

    contacts = @importer.scrape_contacts
    contacts.should.not.be.empty
    contacts.should.be.all { |contact| contact.is_a? Hash }
  end

  private
    def login(username = "foo", password = "bar")
      @importer.options = { :username => username, :password => password }
      @importer.login
    end
end