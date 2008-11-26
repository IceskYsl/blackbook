#
# Provides a base template for interface and behavior of contact importers

module Blackbook::Importer
  class Base
    attr_accessor :options

    ##
    # Should return true or false/nil depending on whether the +options+ given 
    # can be handled by this importer

    def =~( options ); end # stub

    ##
    # Does the work of extracting contacts. Returns an Array of Arrays 
    # containing the name and email as the first and second elements. Of 
    # course, you can override this behavior to meet the needs of a 
    # particular service.

    def fetch_contacts!; end # stub

    ##
    # Imports the contacts using the given +options+. Returns an array of 
    # hashes in the internal format (a hash with at least :name and :email 
    # values).

    def import(options = {}) 
      self.options = options
      fetch_contacts!
    end

    ##
    # Name of the importer service.

    def service_name
      self.class.name.split("::").last
    end
  end
end
