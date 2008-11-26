require 'autotest'

class Autotest::Blackbook < Autotest

  def initialize # :nodoc:
    super
    @exceptions = /\.svn|\.html/
    @test_mappings = {
      %r%^lib/blackbook/([^\/]+)/([^\/]+)\.rb$% => proc { |_, m|
        ["test/test_blackbook_#{m[1]}_#{m[2]}.rb"]
      },
      %r%^lib/blackbook.rb$% => proc { |_, m|
        ["test/test_blackbook.rb"]
      },
      %r%^test/test_blackbook_.*\.rb$% => proc { |filename, _|
        filename
      }
    }
  end

  def path_to_classname(s)
    f = s.sub(/test\/(.+).rb$/, '\1')
    f = f.map { |path| path.split(/_/).map { |seg| seg.capitalize }.join }
    f.join('::')
  end

end
