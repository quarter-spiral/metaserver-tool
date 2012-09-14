Bundler.require

require 'metaserver-tool'

config = YAML.load(File.read(File.expand_path('./config/metaserver.yml', Metaserver::Tool::ROOT)))
server = Metaserver::Tool::Server.new(config)

use Rack::Static, :urls => ["/stylesheets", "/images", "/javascripts"], :root => "assets"

Metaserver::Tool::WebApp.server = server
run Metaserver::Tool::WebApp
