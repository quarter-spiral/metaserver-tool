# Metaserver::Tool

Start/Stop a whole environment of servers.

## Configuration

Copy the ``config/metaserver.yml.example`` file that ships with this tool to ``config/metaserver.yml`` and edit away.

## Loading of fixtures / sample data

It can be necessary to load up data in certain apps to be able to run them (e.g. create a first user in your auth system etc). In order to do so metaserver is setting the ``RUNS_ON_METASERVER`` environment variable in each app it runs. This way you can put whatever logic is needed inside of each app to ensure all the necessary tasks are carried out when it runs on the metaserver.

## Usage

Run the server itself as a webapp

``
cd metaserver-tool
bundle install
bundle exec rackup
``

Now open http://localhost:9292 to see where all your apps have been
booted to and to restart them when necessary.

Stop the server with ``ctrl + c``.
