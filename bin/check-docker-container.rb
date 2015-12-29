#!/usr/bin/env ruby
#
# check-docker-container.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'sensu-plugin/check/cli'
require 'docker'

class CheckDockerContainer < Sensu::Plugin::Check::CLI
  option :url,
         :description => "Docker daemon URL (default: unix:///var/run/docker.sock)",
         :long => "--url <URL>",
         :default => "unix:///var/run/docker.sock"

  def initialize()
    super

    # validate arguments
    raise "Missing container ID" unless ARGV.length > 0
    @container_id = ARGV.first

    Docker.url = config[:url]
  end

  def run()
    begin
      container = Docker::Container.get(@container_id)

      if container.info['State']['Running']
        ok("Container ID '#{@container_id}' is running")
      else
        critical("Container ID '#{@container_id}' is not running")
      end
    rescue Docker::Error::NotFoundError
      critical("Container ID '#{id}' not running on host (Not found)")
    rescue
      unknown("Failed to look up container ID '#{@container_id}' (#{$!})")
    end
  end
end
