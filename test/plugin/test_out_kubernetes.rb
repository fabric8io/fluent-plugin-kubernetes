require 'helper'

class KubernetesOutputTest < Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  CONFIG = %[
  ]

  def create_driver(conf = CONFIG, tag='test')
    Fluent::Test::OutputTestDriver.new(Fluent::KubernetesOutput, tag).configure(conf)
  end

  def test_k8s_pod
    d = create_driver

    d.run do
      d.emit("container_name" => "k8s_CONTAINER.ff8e9ce_POD.NAMESPACE.api_2b249189-c3e0-11e4-839d-54ee7527188d_c306d8a8")
    end
    mapped = {'pod' => 'POD', 'pod_namespace' => 'NAMESPACE', 'pod_container' => 'CONTAINER'}
    assert_equal [
      {"container_name" => "k8s_CONTAINER.ff8e9ce_POD.NAMESPACE.api_2b249189-c3e0-11e4-839d-54ee7527188d_c306d8a8"}.merge(mapped),
    ], d.records

    d.run
  end

  def test_non_k8s_container
    d = create_driver

    d.run do
      d.emit("container_name" => "nonk8s")
    end
    assert_equal [
      {"container_name" => "nonk8s"},
    ], d.records

    d.run
  end

  def bench_k8s_pod
    input = {"container_name" => "k8s_CONTAINER.ff8e9ce_POD.NAMESPACE.api_2b249189-c3e0-11e4-839d-54ee7527188d_c306d8a8"}
    plugin = Fluent::KubernetesOutput.new
    plugin.configure({})
    assert_performance_linear do |n|
      n.times do
        plugin.enrich_record(input)
      end
    end
  end

end
