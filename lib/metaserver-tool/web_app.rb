require 'timeout'

module Metaserver::Tool
  class WebApp < Sinatra::Base
    set :views, File.expand_path('../../assets/views', File.dirname(__FILE__))

    get '/' do
      erb :index, locals: {apps: config.apps}
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

    get '/logs/:app' do
      name = URI.unescape(params[:app])
      app = config.apps.detect {|a| a.name == name}
      raise "App #{name} not found!" unless app

      send_file app.log_file
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
