# Sensu plugin for monitoring Docker containers

A sensu plugin to monitor Docker containers. The plugin can also notify when a container restarts.

## Usage

The plugin accepts the following command line options:

```
Usage: check-docker-container.rb <options> <containerId>
        --uptime <SECONDS>           Warn if UPTIME exceeds the container uptime
        --url <URL>                  Docker daemon URL (default: unix:///var/run/docker.sock)
```

## Author
Matteo Cerutti - <matteo.cerutti@hotmail.co.uk>
