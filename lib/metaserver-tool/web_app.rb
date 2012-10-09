require 'timeout'
require 'eventmachine'

module Metaserver::Tool
  class WebApp < Sinatra::Base
    extend Rack::Utils
    set :views, File.expand_path('../../assets/views', File.dirname(__FILE__))

    get '/' do
      erb :index, locals: {apps: config.apps}
    end

    helpers do
      def stream_log(filename)
        content_type :html
        stream(:keep_open) do |out|
          out << erb(:log_header, layout: false, locals: {filename: filename})
          log = File.open(filename, 'r')
          while !log.eof?
            out << escape_html(log.read_nonblock(16384))
          end
          EventMachine::PeriodicTimer.new(1) do
            out << escape_html(log.read_nonblock(16384)) unless log.eof?
          end
        end
      end
    end

    get '/restart/:app' do
      name = URI.unescape(params[:app])
      app = config.apps.detect {|a| a.name == name}
      raise "App #{name} not found!" unless app

      app.restart!

      begin
        Timeout::timeout(5) do
          while !app.up?
            sleep 0.1
          end
        end
      rescue Timeout::Error
        # Just nothing. Waiting is just to be convenient for the user
        # and show green lights directly when he comes back to the
        # dashboard
      end

      redirect '/'
    end

    get '/stop/:app' do
      name = URI.unescape(params[:app])
      app = config.apps.detect {|a| a.name == name}
      raise "App #{name} not found!" unless app

      app.stop!

      redirect '/'
    end

    get '/logs' do
      metaserver_log = File.expand_path('../../../tmp/metaserver.log', __FILE__)

      stream_log(metaserver_log)
    end

    get '/logs/:app' do
      name = URI.unescape(params[:app])
      app = config.apps.detect {|a| a.name == name}
      raise "App #{name} not found!" unless app

      stream_log(app.log_file)
    end

    def config
      self.class.server.config
    end

    def self.server=(server)
      @server = server
    end

    def self.server
      @server
    end
  end
end
