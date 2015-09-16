describe 'Fluent::MuninNodeInput#configure' do
  let(:fluentd_conf) { {} }
  let(:before_create_driver) {}

  let(:driver) do
    before_create_driver
    create_driver(fluentd_conf)
  end

  subject do
    driver.instance
  end

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
      expect(driver.instance.include_service).to be_nil
      expect(driver.instance.exclude_service).to be_nil
      expect(driver.instance.include_hostname).to be_falsey
      expect(driver.instance.hostname_key).to eq 'hostname'
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
        include_service: 'cpu',
        exclude_service: 'df',
        include_hostname: true,
        hostname_key: 'hostname2'
      }
    end

    let(:before_create_driver) do
      allow_any_instance_of(Fluent::MuninNodeInput).to receive(:hostname) { 'my-host2' }
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
      expect(driver.instance.extra).to eq({"foo"=>"bar", "hostname2"=>"my-host2"})
      expect(driver.instance.bulk).to be_truthy
      expect(driver.instance.include_service).to eq /cpu/
      expect(driver.instance.exclude_service).to eq /df/
      expect(driver.instance.include_hostname).to be_truthy
      expect(driver.instance.hostname_key).to eq 'hostname2'
    end
  end
end
