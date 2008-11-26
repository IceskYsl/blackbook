require 'blackbook/importer/page_scraper'

class Blackbook::Importer::Freenet < Blackbook::Importer::PageScraper
  LOGIN_URL = "https://office.freenet.de"
  MESSAGES_URL = "/main_overview.html"

  def =~( options )
    options && options[:username] =~ /@freenet\.de$/i
  end

  def login
    username, password = options[:username], options[:password]

    begin
      page = agent.get LOGIN_URL

      form = page.forms.with.name("loginform").first
      form.username = username.split("@").first
      form.password = password
      page = form.submit

      if page.body.match(/Fehlgeschlagene Login-Versuche/)
        page = page.forms.with.name("sicherform").submit
        page = agent.get MESSAGES_URL
      end

      if page.body.match(/Login (erneut )?fehlgeschlagen/) || page.body.match(/Ich bin bereits Mitglied/)
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
    contacts = ["INBOX", "INBOX.sent"].map do |folder|
      page = agent.get "/messages/mail_mailbox.html?mail_folder=#{folder}"
      find_contacts(page)
    end

    contacts.inject([]) do |memo, contact|
      memo << contact unless memo.include? contact
      memo
    end.flatten
  end


  protected
    def find_contacts(page)
      page.search("tr[@id]/td[9]").map do |cell|
        recp, fullname, email = *cell.attributes["title"].match(/"(.*)"<(.*)>/)

        { :name => fullname, :email => email }
      end
    end

    Blackbook.register :freenet, self
end