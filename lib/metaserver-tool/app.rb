require 'tempfile'
require 'timeout'

module Metaserver::Tool
  class App
    attr_reader :name, :path, :variable
    attr_accessor :port

    def initialize(name, config, options = {})
      @parent = true
      @name = name
      raise "App must have a name!" unless @name
      @config = config
      @path = options['path']
      raise "App '#{@name} must have a path!" unless @path
      @variable = options['variable']
    end

    def boot!(options = {})
      raise "Can't boot app with no port!" unless port

      kill_by_pid_file!
      run_thin_via_ssh!
    end

    def restart!
      boot!
    end

    def stop!
      kill_by_pid_file!
    end

    def url
      "http://localhost:#{port}/"
    end

    def up?
      return unless pid
      Process.getpgid(pid)
    rescue Errno::ESRCH
      # process is gone, just return nil
    end

    def pid_file
      File.expand_path("./#{name}.pid", Server::TMP_PATH)
    end

    def log_file
      File.expand_path("./#{name}.log", Server::TMP_PATH)
    end

    protected
    def run_thin_via_ssh!
      Process.fork do
        $nopid_deletion = true
        old_authorized_key_file = prepare_ssh_config!

        variables = @config.variables.map {|variable, value| "#{variable}=\"#{value}\""}.join(" ")

        command = "/bin/bash -l -c 'cd #{project_path}; RUNS_ON_METASERVER=1 #{variables} bundle exec rackup -p #{@port}  -O --threaded > #{log_file} 2> #{log_file} & echo \\$! > #{pid_file}; wait \\$!'"
        puts "Running #{command}"
        `ssh -i ~/.ssh/#{key_file} localhost "#{command}"`

        remove_ssh_config!(old_authorized_key_file)
        exit
      end
    end

    def home
      File.expand_path(".", "~")
    end

    def prepare_ssh_config!
      old_authorized_key_file = ''
      `touch ~/.ssh/#{key_file}`
      `rm ~/.ssh/#{key_file}*`
      `ssh-keygen -v -t dsa -f ~/.ssh/#{key_file} -N ""`
      old_authorized_key_file = File.read(File.expand_path("./.ssh/authorized_keys", home))
      `cat ~/.ssh/#{key_file}.pub >> ~/.ssh/authorized_keys`
      old_authorized_key_file
    end

    def key_file
      "__metaserver_key_#{port}"
    end

    def remove_ssh_config!(old_authorized_key_file)
      `rm ~/.ssh/#{key_file}*`
      File.open(File.expand_path("./.ssh/authorized_keys", home), 'w') {|f| f.write old_authorized_key_file}
    end

    def pid
      return unless File.exist?(pid_file)
      pid = File.read(pid_file).chomp.to_i
    end

    def project_path
      File.dirname(path)
    end

    def path
      @path if @path.end_with?('.ru')
      File.expand_path('./config.ru', @path)
    end

    def kill_by_pid_file!(hardcore = false)
      return unless pid

      Timeout::timeout(10) {
        while pid
          Process.kill(hardcore ? "KILL" : "TERM", pid)
          sleep 2
        end
      }
    rescue Timeout::Error
      if hardcore
        raise "Can't stop the pid #{pid} of app #{name}. Timed out. Aborting!"
      else
        kill_by_pid_file!(true)
      end
    rescue Errno::ESRCH
      # good, process is dead
    end
  end
end
