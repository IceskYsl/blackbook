require 'blackbook/importer/page_scraper'

class Blackbook::Importer::GMX < Blackbook::Importer::PageScraper
  LOGIN_URL = "https://www.gmx.net/"

  def =~( options )
    options && options[:username] =~ /@gmx\.(de|net)$/i
  end

  def login
    username, password = options[:username], options[:password]

    begin
      page = agent.get LOGIN_URL

      form = page.forms.with.name("login").first
      form.id = username
      form.p = password
      page = form.submit
      @next = page

      if (page.at("div.index") && page.at("div.index").inner_html == "Passwort vergessen?") ||
        page.uri.to_s.match(/login-failed/)
        raise Blackbook::BadCredentialsError.new
      end
    rescue => e
      raise e || Blackbook::BlackbookError.new
    end
  end

  def prepare
    login
  end

  def scrape_contacts
    page = @next

    # Go to E-Mails
    page = page.links.select { |link| link.text =~ /E-Mail/ }.first.click

    contacts = [/Posteingang/, /Archiv/, /Gesendet/].map do |folder|
      # puts "folder: #{folder}"
      # puts "page title: #{page.title}"
      # puts "page links: #{page.links.select { |link| link.text =~ folder }}"
      page = page.links.select { |link| link.text =~ folder }.first.click
      find_contacts(page)
    end

    contacts.inject([]) do |memo, contact|
      memo << contact unless memo.include? contact
      memo
    end.flatten
  end

  protected

    def find_contacts(page)
      links = page.search("form#MI a").select { |link| link.attributes["title"] =~ /@/ }
      links.map do |link|
        recp = link.attributes["title"].gsub(/\n/, "").split(/\s/)
        email = recp.pop.gsub(/[<>]/, "")
        fullname = recp.join(" ")

        { :name => fullname, :email => email }
      end
    end
    Blackbook.register :gmx, self
end
