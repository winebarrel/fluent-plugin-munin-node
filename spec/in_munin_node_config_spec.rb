describe 'Fluent::MuninNodeInput#configure' do
  let(:fluentd_conf) { {} }

  let(:driver) do
    create_driver(fluentd_conf)
  end

  subject { create_driver(fluentd_conf).instance }

  context 'when default' do
    it do
      expect(driver.instance.node_host).to eq '127.0.0.1'
      expect(driver.instance.node_port).to eq 4949
      expect(driver.instance.interval).to eq 60
      expect(driver.instance.tag_prefix).to eq 'munin'
      expect(driver.instance.bulk_suffix).to eq 'metrics'
      expect(driver.instance.service_key).to eq 'service'
      expect(driver.instance.field_key).to eq 'field'
      expect(driver.instance.value_key).to eq 'value'
      expect(driver.instance.extra).to eq({})
      expect(driver.instance.bulk).to be_falsey
    end
  end

  context 'when not default' do
    let(:fluentd_conf) do
      {
        node_host: '127.0.0.2',
        node_port: 5959,
        interval: 61,
        tag_prefix: 'munin2',
        bulk_suffix: 'metrics2',
        service_key: 'service2',
        field_key: 'field2',
        value_key: 'value2',
        extra: '{"foo":"bar"}',
        bulk: true,
      }
    end

    it do
      expect(driver.instance.node_host).to eq '127.0.0.2'
      expect(driver.instance.node_port).to eq 5959
      expect(driver.instance.interval).to eq 61
      expect(driver.instance.tag_prefix).to eq 'munin2'
      expect(driver.instance.bulk_suffix).to eq 'metrics2'
      expect(driver.instance.service_key).to eq 'service2'
      expect(driver.instance.field_key).to eq 'field2'
      expect(driver.instance.value_key).to eq 'value2'
      expect(driver.instance.extra).to eq({"foo"=>"bar"})
      expect(driver.instance.bulk).to be_truthy
    end
  end
end
