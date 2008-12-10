require 'blackbook/importer/page_scraper'
##
# contacts importer for Netease(163)!

class Blackbook::Importer::Netease < Blackbook::Importer::PageScraper

  ##
  # Matches this importer to an user's name/address

  def =~(options = {})
    options && options[:username] =~ /@163.com$/i ? true : false
  end

  ##
  # login for Netease

  def login
    puts "options[:username]=#{options[:username]},options[:password]=#{options[:password]}"
    page = agent.get('http://reg.163.com/login.jsp')
    form = page.forms.first
    #    pp form
    form.username = options[:username].split("@").first
    form.password = options[:password]
    page = agent.submit(form, form.buttons.first)

    # Check for login success
    raise( Blackbook::BadCredentialsError, "That username and password was not accepted. Please check them and try again." ) if page.body =~ /对不起，您的密码不正确!/
    true
  end

  ##
  # prepare the importer

  def prepare
    login
  end

  ##
  # scrape Netease contacts

  def scrape_contacts
    page = agent.get("http://fm163.163.com/coremail/fcg/ntesdoor2?verifycookie=1&lightweight=1")
    if page.body =~ /网易通行证登录超时/m
      raise( Blackbook::BadCredentialsError, "网易通行证登录超时." )
    end

    puts "page.uri=#{page.uri}"
    #page.uri=http://tg1a104.mail.163.com/a/j/js3/main.jsp?sid=NCjWpiPPVlLLvWuckzPPJtZbFElpHMjQ
    if page.uri.to_s =~ /^http:\/\/(.+)\.mail.*sid=(.+)$/
      fre,sid  = $1,$2
      puts "fre,sid =#{fre },#{sid}"
    end

    #http://tg1a137.mail.163.com/jy3/address/addrlist.jsp?sid=CDvXnnooIioJnRTIFPoouBbqyouQBkOo
    address_url = "http://#{fre}.mail.163.com/jy3/address/addrlist.jsp?sid=#{sid}"
    page = agent.get(address_url)
    if page.body =~ /操作超时/m
      raise( Blackbook::BadCredentialsError, "操作超时." )
    end

    #联系人列表
    address = (page/"/html/body/div/div/form/div[2]/div/table/tbody/tr")
    contacts = []
    address.each do |c|
      name ,email = "",""
      (c/"td").each_with_index do |cc,i|
        #<a href="addrdetail.jsp?sid=CDvXnnooIioJnRTIFPoouBbqyouQBkOo&amp;puid=27&amp;gid=" title="查看用户信息">"jc"</a>
        inner = cc.inner_text.gsub(/<\/?[^>]*>/, "")
#        puts "i=#{i},inner=#{inner}"
        case i
        when 1
          name = inner
        when 2
          email = inner
        end
      end
#      puts "name=#{name},email=#{email}"
      contacts << {:name  =>name,:email=>email}
    end
#    puts "contacts=#{contacts.class}"
    #返回列表
    return contacts
  end

  Blackbook.register(:netease, self)
end
