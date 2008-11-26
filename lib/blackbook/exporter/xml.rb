require 'rexml/document'

##
# exports contacts in xml format

class Blackbook::Exporter::Xml < Blackbook::Exporter::Base

  ##
  # contacts are an array of hashes that are contacts and returns xml

  def export( contacts )
    doc = REXML::Document.new
    doc << REXML::XMLDecl.new
    
    root = doc.add_element 'contacts'
    contacts.each do |contact|
      el = root.add_element 'contact'
      name = el.add_element 'name' 
      name.text = contact[:name]
      
      el.add_element('email').text = contact[:email]
    end
    
    doc.to_s
  end
  
  Blackbook.register(:xml, self)
end
