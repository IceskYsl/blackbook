##
# exports contacts in Vcard format
class Blackbook::Exporter::Vcf < Blackbook::Exporter::Base

  ##
  # representation of a vcard

  class Vcard

    attr_accessor :first, :last, :email
    
    ##
    # initialize dynamically sets the attributes passed in as accessible 
    # attribute on its object

    def initialize( attributes = {} )
      attributes.each{ |name,value| self.send("#{name}=", value) rescue next }
    end
    
    ##
    # text representation of this vcard
    def to_s
      <<-EOVC
BEGIN:VCARD
N:#{last};#{first}
EMAIL:#{email}
END:VCARD
      EOVC
    end
  end

  ##
  # exports contacts as Vcards

  def export( contacts = [] )
    return if contacts.blank? 
    
    contacts.uniq.compact.collect do |contact|
      first_name, last_name = contact[:name].split(' ', 2)
      Vcard.new( :first => first_name.to_s, :last => last_name.to_s, :email => contact[:email])
    end
  end
  
  Blackbook.register(:vcf, self)
end
