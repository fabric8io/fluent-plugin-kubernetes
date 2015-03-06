require 'open3'

class Fluent::KubernetesOutput < Fluent::Output
  Fluent::Plugin.register_output('kubernetes', self)

  K8S_CONTAINER_NAME_REGEX = '^[^_]+_([^\.]+)\.[^_]+_([^\.]+)\.([^\.]+)'

  def initialize
    super
  end

  def configure(conf)
    super

    @egrep_cmd = "egrep \"#{K8S_CONTAINER_NAME_REGEX}\""
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      Fluent::Engine.emit(tag, time, enrich_record(record))
    end

    chain.next
  end

  def enrich_record(record)
    if record.has_key? "container_name"
      regex = Regexp.new(K8S_CONTAINER_NAME_REGEX)
      match = record["container_name"].match(regex)
      if match
        pod_container_name, pod_name, pod_namespace =
          match.captures
        record["pod_namespace"] = pod_namespace
        record["pod"] = pod_name
        record["pod_container"] = pod_container_name
      end
    end
    record
  end

end
