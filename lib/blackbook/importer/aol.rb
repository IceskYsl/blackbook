require 'blackbook/importer/page_scraper'

##
# Imports contacts from AOL

class Blackbook::Importer::Aol < Blackbook::Importer::PageScraper

  ##
  # Matches this importer to an user's name/address

  def =~( options )
    options && options[:username] =~ /@(aol|aim)\.com$/i ? true : false
  end
  
  ##
  # Login process:
  # - Get mail.aol.com which redirects to a page containing a javascript redirect
  # - Get the URL that the javascript is supposed to redirect you to
  # - Fill out and submit the login form
  # - Get the URL from *another* javascript redirect

  def login
    page = agent.get( 'http://webmail.aol.com/' )

    form = page.forms.name('AOLLoginForm').first
    form.loginId = options[:username].split('@').first # Drop the domain
    form.password = options[:password]
    page = agent.submit(form, form.buttons.first)

    raise( Blackbook::BadCredentialsError, "That username and password was not accepted. Please check them and try again." ) if page.body =~ /Invalid Screen Name or Password. Please try again./

    # aol bumps to a wait page while logging in.  if we can't scrape out the js then its a bad login
    wait_url = page.body.scan(/onLoad="checkError[^\)]+/).first.scan(/'([^']+)'/).last.first
    page = agent.get wait_url

    base_uri = page.body.scan(/^var gSuccessPath = \"(.+)\";/).first.first
    raise( Blackbook::BadCredentialsError, "You do not appear to be signed in." ) unless base_uri
    page = agent.get base_uri
  end
  
  ##
  # must login to prepare

  def prepare
    login
  end
  
  ##
  # The url to scrape contacts from has to be put together from the Auth cookie
  # and a known uri that hosts their contact service. An array of hashes with
  # :name and :email keys is returned.

  def scrape_contacts
    unless auth_cookie = agent.cookies.find{|c| c.name =~ /^Auth/}
      raise( Blackbook::BadCredentialsError, "Must be authenticated to access contacts." )
    end
    
    # jump through the hoops of formulating a request to get printable contacts
    uri = agent.current_page.uri.dup
    inputs = agent.current_page.search("//input")
    user = inputs.detect{|i| i['type'] == 'hidden' && i['name'] == 'user'}
    utoken = user['value']

    path = uri.path.split('/')
    path.pop
    path << 'addresslist-print.aspx'
    uri.path = path.join('/')
    uri.query = "command=all&sort=FirstLastNick&sortDir=Ascending&nameFormat=FirstLastNick&user=#{utoken}"
    page = agent.get uri.to_s

    # Grab all the contacts
    names = page.body.scan( /<span class="fullName">([^<]+)<\/span>/ ).flatten
    emails = page.body.scan( /<span>Email 1:<\/span> <span>([^<]+)<\/span>/ ).flatten
    (0...[names.size,emails.size].max).collect do |i|
      {
        :name => names[i],
        :email => emails[i]
      }
    end
  end
  
  Blackbook.register :aol, self
end
