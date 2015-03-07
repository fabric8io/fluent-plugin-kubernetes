require 'open3'

class Fluent::KubernetesOutput < Fluent::Output
  Fluent::Plugin.register_output('kubernetes', self)

  config_param :container_id, :string
  config_param :tag, :string
  config_param :kubernetes_pod_regex, :string, default: '^[^_]+_([^\.]+)\.[^_]+_([^\.]+)\.([^\.]+)'

  def initialize
    super
  end

  def configure(conf)
    super

    require 'docker'
  end

  def emit(tag, es, chain)
    es.each do |time,record|
      Fluent::Engine.emit('kubernetes',
                          time,
                          enrich_record(tag, record))
    end

    chain.next
  end

  private

  def interpolate(tag, str)
    tag_parts = tag.split('.')

    str.gsub(/\$\{tag_parts\[(\d+)\]\}/) { |m| tag_parts[$1.to_i] }
  end

  def enrich_record(tag, record)
    if @container_id
      id = interpolate(tag, @container_id)
      record['container_id'] = id
      container = Docker::Container.get(id)
      if container
        container_name = container.json['Name']
        if container_name
          record["container_name"] = container_name
          regex = Regexp.new(@kubernetes_pod_regex)
          match = container_name.match(regex)
          if match
            pod_container_name, pod_name, pod_namespace =
              match.captures
            record["pod_namespace"] = pod_namespace
            record["pod"] = pod_name
            record["pod_container"] = pod_container_name
          end
        end
      end
    end
    record
  end

end
