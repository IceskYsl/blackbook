require 'blackbook/importer/page_scraper'

##
# Imports contacts from GMail

class Blackbook::Importer::Gmail < Blackbook::Importer::PageScraper

  ##
  # Matches this importer to an user's name/address

  def =~(options = {})
    options && options[:username] =~ /@gmail.com$/i ? true : false
  end
  
  ##
  # login to gmail

  def login
    page = agent.get('http://mail.google.com/mail/')
    form = page.forms.first
    form.Email = options[:username]
    form.Passwd = options[:password]
    page = agent.submit(form,form.buttons.first)
    
    raise( Blackbook::BadCredentialsError, "That username and password was not accepted. Please check them and try again." ) if page.body =~ /Username and password do not match/
    
    if page.search('//meta').first.attributes['content'] =~ /url='?(http.+?)'?$/i
      page = agent.get $1
    end
  end
  
  ##
  # prepare this importer

  def prepare
    login
  end
  
  ##
  # scrape gmail contacts for this importer

  def scrape_contacts
    unless agent.cookies.find{|c| c.name == 'GAUSR' && 
                           c.value == "mail:#{options[:username]}"}
      raise( Blackbook::BadCredentialsError, "Must be authenticated to access contacts." )
    end
    
    page = agent.get('http://mail.google.com/mail/h/?v=cl&pnl=a')
    contact_rows = page.search("input[@name='c']/../..")
    contact_rows.collect do |row|
      columns = row/"td"
      { 
        :name  => ( columns[1] / "b" ).inner_html, # name
        :email => columns[2].inner_html.gsub( /(\n|&nbsp;)/, '' ) # email
      }
    end
  end
  
  Blackbook.register(:gmail, self)
end
