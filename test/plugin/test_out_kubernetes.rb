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
require 'helper'

describe 'Fluentd Kubernetes Output Plugin' do

  CONFIG = %{
    container_id ${tag_parts[5]}
    tag docker.${name}
  }

  before do
    Fluent::Test.setup
    @fluentd_driver = Fluent::Test::OutputTestDriver.new(
      Fluent::KubernetesOutput, 
      'docker.var.lib.docker.containers.9b26b527e73550b1fb217d0d643b15aa2ec6607593a6b477cda82a9c72cb82a7')
    .configure(CONFIG)
  end

  describe 'add kubernetes metadata', vcr: {record: :once} do
    describe 'kubernetes container' do
      it 'enriches with correct kubernets metadata' do
        @fluentd_driver.run do
          @fluentd_driver.emit("container_name" => "k8s_CONTAINER.ff8e9ce_POD.NAMESPACE.api_2b249189-c3e0-11e4-839d-54ee7527188d_c306d8a8")
        end
        mapped = {'container_id' => '9b26b527e73550b1fb217d0d643b15aa2ec6607593a6b477cda82a9c72cb82a7', 'pod' => 'POD', 'pod_namespace' => 'NAMESPACE', 'pod_container' => 'CONTAINER'}
        assert_equal [
          {"container_name" => "k8s_CONTAINER.ff8e9ce_POD.NAMESPACE.api_2b249189-c3e0-11e4-839d-54ee7527188d_c306d8a8"}.merge(mapped),
        ], @fluentd_driver.records

        @fluentd_driver.run
      end
    end
    describe 'non-kubernetes container' do
      it 'leaves event untouched' do
        @fluentd_driver.run do
          @fluentd_driver.emit("container_name" => "/non-kubernetes")
        end
        assert_equal [
          {'container_id' => '9b26b527e73550b1fb217d0d643b15aa2ec6607593a6b477cda82a9c72cb82a7', "container_name" => "non-kubernetes"},
        ], @fluentd_driver.records

        @fluentd_driver.run
      end
    end
    describe 'container name not starting with slash' do
      it 'uses full container name' do
        @fluentd_driver.run do
          @fluentd_driver.emit("container_name" => "no-leading-slash")
        end
        assert_equal [
          {'container_id' => '9b26b527e73550b1fb217d0d643b15aa2ec6607593a6b477cda82a9c72cb82a7', "container_name" => "no-leading-slash"},
        ], @fluentd_driver.records

        @fluentd_driver.run
      end
    end
    describe 'json log data' do
      it 'merges json log data' do
        @fluentd_driver.run do
          @fluentd_driver.emit({"container_name" => "non-kubernetes", "log" => "{\"this\":\"rocks\"}"})
        end
        assert_equal [
          {'container_id' => '9b26b527e73550b1fb217d0d643b15aa2ec6607593a6b477cda82a9c72cb82a7', "container_name" => "non-kubernetes", "this" => "rocks"},
        ], @fluentd_driver.records

        @fluentd_driver.run
      end
    end
  end

end
