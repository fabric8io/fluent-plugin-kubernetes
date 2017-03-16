#
# Fluentd Kubernetes Output Plugin - Enrich Fluentd events with Kubernetes
# metadata
#
# Copyright 2015 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
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
    require 'json'
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
    id = interpolate(tag, @container_id)
    if !id.empty?
      record['container_id'] = id
      record = enrich_container_data(id, record)
      record = merge_json_log(record)
    end
    record
  end

    #logging purposes only
def logmetofile(value)
  File.open("output.txt","a") do |f|
              f.puts value
   end
end
# This is changed for all versions of
def enrich_container_data(id, record)
    container = Docker::Container.get(id)
        #logmetofile(container.json['Config']['Labels'])
    if container
      record["container_name"]= container.json['Config']['Labels']['io.kubernetes.container.name']
      #logmetofile(container.json['Config']['Labels']['io.kubernetes.container.name'])
      record["pod_namespace"] = container.json['Config']['Labels']['io.kubernetes.pod.namespace']
      #logmetofile(container.json['Config']['Labels']['io.kubernetes.pod.namespace'])
      record["pod"] = container.json['Config']['Labels']['io.kubernetes.pod.name']
      #logmetofile(container.json['Config']['Labels']['io.kubernetes.pod.name'])
      record["pod_UID"] = container.json['Config']['Labels']['io.kubernetes.pod.uid']
      #logmetofile(container.json['Config']['Labels']['io.kubernetes.pod.uid'])
    end
    record
  end

  def merge_json_log(record)
    if record.has_key?('log')
      log = record['log'].strip
      if log[0].eql?('{') && log[-1].eql?('}')
        begin
          parsed_log = JSON.parse(log)
          record = record.merge(parsed_log)
          unless parsed_log.has_key?('log')
            record.delete('log')
          end
        rescue JSON::ParserError
        end
      end
    end
    record
  end

end
