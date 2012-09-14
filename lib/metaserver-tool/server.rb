module Metaserver::Tool
  class Server

    TMP_PATH = File.expand_path('./tmp', Metaserver::Tool::ROOT)

    attr_reader :config

    def initialize(config)
      @config = Config.new(config)

      port = @config.base_port
      @config.apps.each do |app|
        port += 1
        app.port = port
      end

      @config.apps.each do |app|
        puts "Booting: #{app.name}"
        app.boot!
      end

      # prepare tmp dir
      Dir.mkdir(TMP_PATH) unless File.exist?(TMP_PATH)

      at_exit do
        unless $nopid_deletion
          threads = []
          @config.apps.each do |app|
            threads << Thread.new do
              puts "Stopping #{app.name}"
              app.send(:kill_by_pid_file!)
            end
          end
          threads.each {|thread| thread.join}
        end
      end
    end
  end
end
