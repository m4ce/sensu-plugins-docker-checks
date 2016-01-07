#!/usr/bin/env ruby
#
# check-docker-container.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'sensu-plugin/check/cli'
require 'docker'
require 'fileutils'
require 'date'

class CheckDockerContainer < Sensu::Plugin::Check::CLI
  banner "Usage: #{$0} <options> <containerId>"

  option :url,
         :description => "Docker daemon URL (default: unix:///var/run/docker.sock)",
         :long => "--url <URL>",
         :default => "unix:///var/run/docker.sock"

  option :uptime,
         :description => "Warn if UPTIME exceeds the container uptime",
         :long => "--uptime <SECONDS>",
         :default => 300

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

      started_at = DateTime.parse(container.info['State']['StartedAt']).to_time
      finished_at = DateTime.parse(container.info['State']['FinishedAt']).to_time

      uptime = Time.now - started_at
      if uptime <= config[:uptime] and finished_at != DateTime.parse('0001-01-01T00:00:00Z').to_time
        warning("Container ID '#{@container_id}' restarted #{uptime.to_i} seconds ago")
      elsif container.info['State']['Restarting']
        warning("Container ID '#{@container_id}' is restarting")
      elsif container.info['State']['Running']
        ok("Container ID '#{@container_id}' is running")
      else
        critical("Container ID '#{@container_id}' is not running")
      end
    rescue Docker::Error::NotFoundError
      critical("Container ID '#{@container_id}' not running on host (Reason: Not found)")
    rescue
      unknown("Failed to look up container ID '#{@container_id}' (Reason: #{$!})")
    end
  end
end
