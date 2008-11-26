##
# base class for exporters of contact information

module Blackbook::Exporter

  class Base
    ##
    # Override this to convert +contacts+ (an array of hashes) to something more useful. Here, it
    # just returns Blackbook's internal format
    def export( contacts )
      contacts
    end
    
    Blackbook.register :basic, self
  end
end
