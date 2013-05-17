module Metaserver::Tool
  class Config
    attr_reader :base_port, :apps

    def initialize(options = {})
      @base_port = options['base_port'] || DEFAULT_BASE_PORT
      @apps = build_apps(options['apps'])
    end

    def variables
      Hash[apps.map {|app| [app.variable, app.url] if app.variable}.compact]
    end

    protected
    def build_apps(apps)
      @apps = apps.map do |name, app|
        App.new(name, self, app) if app['path']
      end.compact
    end
  end
end
