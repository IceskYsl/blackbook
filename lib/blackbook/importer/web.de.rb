require 'blackbook/importer/page_scraper'

class Blackbook::Importer::WebDE < Blackbook::Importer::PageScraper
  LOGIN_URL = "https://freemail.web.de"

  def =~( options )
    options && options[:username] =~ /@web\.de$/i
  end

  def login
    username, password = options[:username], options[:password]

    begin
      page = agent.get LOGIN_URL

      form = page.forms.with.name("login").first
      form.username = username
      form.password = password

      page = form.submit
      # follow logout hint
      if (continue_link = page.links.select { |link| link.text =~ /weiter zu FreeMail/ }.first)
        page = continue_link.click
      end

      if page.uri.to_s.match(/logonfailed/)
        raise Blackbook::BadCredentialsError.new
      end

      # follow content frame
      @next = agent.get page.frames[1].src
    rescue => e
      raise e || Blackbook::BlackbookError.new
    end
  end

  def prepare
    login
  end

  def scrape_contacts
    page = @next

    contacts = [/Posteingang/, /Unbekannt/].map do |folder|
      page = page.links.select { |link| link.text =~ folder }.first.click
      find_contacts(page)
    end

    contacts.inject([]) do |memo, contact|
      memo << contact unless memo.include? contact
      memo
    end
  end

  protected
    def find_contacts(page)
      page.search("span.from a").map do |link|
        recp = link.attributes["title"].gsub(/\n/, "").split(/\s/)
        email = recp.pop
        fullname = recp.join(" ")

        { :name => fullname, :email => email }
      end
    end

    Blackbook.register :webde, self
end