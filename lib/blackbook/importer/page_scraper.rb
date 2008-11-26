require 'rubygems'
gem 'mechanize', '>= 0.7.0'
require 'mechanize'
require 'generator' # for SyncEnumerator

# Patch Mechanize's broken html unescaping Mechanize 0.6.11
class WWW::Mechanize
  def to_absolute_uri(url, cur_page=current_page())
    unless url.is_a? URI
      url = url.to_s.strip
      url = URI.parse(
              self.class.html_unescape(
                SyncEnumerator.new(
                  url.split(/%[0-9A-Fa-f]{2}/), url.scan(/%[0-9A-Fa-f]{2}/)
                ).map { |x,y|
                  "#{URI.escape(x||'')}#{y}"
                }.join('').gsub(/%23/, '#')
              )
            )
      # Mechanize here uses #zip to combine the two arrays, which will ignore 
      # excessive elements of the second array (the one which is passed as an 
      # argument). That means if the URL ends with more than one already escaped
      # character, then only the first one will be restored into the resulting
      # URL.
    end

    # construct an absolute uri
    if url.relative?
      raise 'no history. please specify an absolute URL' unless cur_page.uri
      url = cur_page.uri + url
      # Strip initial "/.." bits from the path
      url.path.sub!(/^(\/\.\.)+(?=\/)/, '')
    end

    return url
  end
end

##
# A base class for importers that scrape their contacts from web services

class Blackbook::Importer::PageScraper < Blackbook::Importer::Base

  attr_accessor :agent
  
  ##
  # creates the Mechanize agent used to do the scraping and sets a nice
  # user agent header for good net educate 

  def create_agent
    self.agent = WWW::Mechanize.new
    agent.user_agent = "Mozilla/4.0 (compatible; Blackbook #{Blackbook::VERSION})"
    agent.keep_alive = false
    agent
  end
  
  ##
  # Page scrapers will follow a fairly simple pattern of instantiating the 
  # agent, prepping for the scrape and then the actual scrape process

  def fetch_contacts!
    create_agent
    prepare
    scrape_contacts
  end
  
  ##
  # Providers will often require you to login or otherwise prepare to actual 
  # scrape the contacts

  def prepare; end # stub

  ##
  # Some providers have a single page you can scrape from (like Gmail's HTML 
  # Contacts page) while others might require you to navigate several pages, 
  # scraping as you go.

  def scrape_contacts; end # stub
  
  ##
  # helper to strip html from text

  def strip_html( html )
    html.gsub(/<\/?[^>]*>/, '')
  end
end
