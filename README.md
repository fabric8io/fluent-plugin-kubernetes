# fluent-plugin-kubernetes, a plugin for [Fluentd](http://fluentd.org)
[![Circle CI](https://circleci.com/gh/fabric8io/fluent-plugin-kubernetes.svg?style=svg)](https://circleci.com/gh/fabric8io/fluent-plugin-kubernetes)
[![Code Climate](https://codeclimate.com/github/fabric8io/fluent-plugin-kubernetes/badges/gpa.svg)](https://codeclimate.com/github/fabric8io/fluent-plugin-kubernetes)
[![Test Coverage](https://codeclimate.com/github/fabric8io/fluent-plugin-kubernetes/badges/coverage.svg)](https://codeclimate.com/github/fabric8io/fluent-plugin-kubernetes)

## Installation

    gem install fluent-plugin-kubernetes

## Configuration
```
<source>
  type tail
  path /var/lib/docker/containers/*/*-json.log
  pos_file fluentd-docker.pos
  time_format %Y-%m-%dT%H:%M:%S
  tag docker.*
  format json
  read_from_head true
</source>

<match docker.var.lib.docker.containers.*.*.log>
  type kubernetes
  container_id ${tag_parts[5]}
  tag docker.${name}
</match>

<match kubernetes>
  type stdout
</match>
```

### Assuming following inputs are coming:
    test.aa: {"container_name":"k8s_CONTAINER.2f44475a_POD.NAMESPACE.api_ae0aeb72-c44f-11e4-a274-54ee7527188d_d442134f", "json":"dayo"}
### then output becomes as belows
    test.aa: {"container_name":"k8s_CONTAINER.2f44475a_POD.NAMESPACE.api_ae0aeb72-c44f-11e4-a274-54ee7527188d_d442134f", "pod":"POD", "pod_namespace":"NAMESPACE", "pod_container":"CONTAINER", "json":"dayo", "hoge":"moge","hogehoge":"mogemoge"}

## JSON logging

Logging requires context to be really useful. Context can either be derived
from log lines from known formats, but this is error prone & requires
processing power. The logging application is the best place to add
context.

If you use JSON for your application logs you can add context to your logs
as you go. This plugin will parse your log lines & if it sees that they are
JSON it will merge it in to the top level record so your contextual logging
will be nicely searchable.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright
    Copyright (c) 2015 jimmidyson
