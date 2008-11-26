module TestHelper

  def fixture_path(name)
    "#{File.dirname(__FILE__)}/fixtures/#{name}"
  end

  def load_fixture(file)
    IO.readlines(fixture_path(file))
  end

  def fixture_file(name)
    File.new fixture_path(name)
  end

end

module Net #:nodoc:
  class HTTP #:nodoc:

    extend TestHelper

    RESPONSES = {}

    def self.responses=(r)
      RESPONSES.clear
      r.each{|k,v| RESPONSES[k] = v}
    end


    alias :old_net_http_request :request

    def request(req, body = nil, &block)
      prot = use_ssl ? "https" : "http"
      uri_cls = use_ssl ? URI::HTTPS : URI::HTTP
      query = req.path.split('?',2)
      opts = {:host => self.address,
             :port => self.port, :path => query[0]}
      opts[:query] = query[1] if query[1]
      uri = uri_cls.build(opts)
      raise ArgumentError.new("#{req.method} method to #{uri} not being handled in testing")
    end

    def connect
      raise ArgumentError.new("connect not being handled in testing")
    end
  end
end

plugin_root = "#{ File.dirname(__FILE__) }/.."

require 'rubygems'
require 'test/spec'
require 'mocha'

module BlackbookExtensions
  module TestHelper
    class Credentials
      attr_accessor :network, :config

      def initialize(network)
        self.network = network.to_s
        self.config = YAML.load_file( File.join(File.dirname(__FILE__), "config/credentials.yml") )
      end

      def get
        [ self.config[self.network]["username"], self.config[self.network]["password"] ]
      end
    end
  end
end