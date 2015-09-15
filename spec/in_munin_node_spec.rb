describe Fluent::MuninNodeInput do
  let(:default_fluentd_conf) do
    {
      interval: 0,
    }
  end

  let(:fluentd_conf) { default_fluentd_conf }
  let(:before_driver_run) {}

  let(:driver) do
    create_driver(fluentd_conf)
  end

  subject { driver.emits }

  before do
    before_driver_run
    driver.run
  end

  context 'when get munin services' do
    it do
      is_expected.to match_array [
        ["munin.cpu.guest", 1432492200, {"service"=>"cpu", "field"=>"guest", "value"=>0}],
        ["munin.cpu.idle", 1432492200, {"service"=>"cpu", "field"=>"idle", "value"=>89532}],
        ["munin.cpu.iowait", 1432492200, {"service"=>"cpu", "field"=>"iowait", "value"=>37}],
        ["munin.cpu.irq", 1432492200, {"service"=>"cpu", "field"=>"irq", "value"=>0}],
        ["munin.cpu.nice", 1432492200, {"service"=>"cpu", "field"=>"nice", "value"=>0}],
        ["munin.cpu.softirq", 1432492200, {"service"=>"cpu", "field"=>"softirq", "value"=>27}],
        ["munin.cpu.steal", 1432492200, {"service"=>"cpu", "field"=>"steal", "value"=>0}],
        ["munin.cpu.system", 1432492200, {"service"=>"cpu", "field"=>"system", "value"=>507}],
        ["munin.cpu.user", 1432492200, {"service"=>"cpu", "field"=>"user", "value"=>556}],
        ["munin.df._dev_sda1", 1432492200, {"service"=>"df", "field"=>"_dev_sda1", "value"=>4.60792528975668}],
        ["munin.df._run", 1432492200, {"service"=>"df", "field"=>"_run", "value"=>0.685586734693878}],
        ["munin.df._run_lock", 1432492200, {"service"=>"df", "field"=>"_run_lock", "value"=>0}],
        ["munin.df._run_shm", 1432492200, {"service"=>"df", "field"=>"_run_shm", "value"=>0}],
        ["munin.df._run_user", 1432492200, {"service"=>"df", "field"=>"_run_user", "value"=>0}],
        ["munin.df._sys_fs_cgroup", 1432492200, {"service"=>"df", "field"=>"_sys_fs_cgroup", "value"=>0}],
        ["munin.df.vagrant", 1432492200, {"service"=>"df", "field"=>"vagrant", "value"=>36.4856735523352}],
      ]
    end
  end

  context 'when get munin services as a single record' do
    let(:fluentd_conf) do
      default_fluentd_conf.merge(bulk: true)
    end

    it do
      is_expected.to match_array [
       ["munin.metrics",
        1432492200,
        {"cpu"=>
          {"user"=>"556",
           "nice"=>"0",
           "system"=>"507",
           "idle"=>"89532",
           "iowait"=>"37",
           "irq"=>"0",
           "softirq"=>"27",
           "steal"=>"0",
           "guest"=>"0"},
         "df"=>
          {"_dev_sda1"=>"4.60792528975668",
           "_sys_fs_cgroup"=>"0",
           "_run"=>"0.685586734693878",
           "_run_lock"=>"0",
           "_run_shm"=>"0",
           "_run_user"=>"0",
           "vagrant"=>"36.4856735523352"}}]]
    end
  end

  context 'when get munin services with extra' do
    let(:extra) { {"hostname" => "my-host"} }

    let(:fluentd_conf) do
      default_fluentd_conf.merge(extra: JSON.dump(extra))
    end

    it do
      is_expected.to match_array [
        ["munin.cpu.guest", 1432492200, {"service"=>"cpu", "field"=>"guest", "value"=>0, "hostname"=>"my-host"}],
        ["munin.cpu.idle", 1432492200, {"service"=>"cpu", "field"=>"idle", "value"=>89532, "hostname"=>"my-host"}],
        ["munin.cpu.iowait", 1432492200, {"service"=>"cpu", "field"=>"iowait", "value"=>37, "hostname"=>"my-host"}],
        ["munin.cpu.irq", 1432492200, {"service"=>"cpu", "field"=>"irq", "value"=>0, "hostname"=>"my-host"}],
        ["munin.cpu.nice", 1432492200, {"service"=>"cpu", "field"=>"nice", "value"=>0, "hostname"=>"my-host"}],
        ["munin.cpu.softirq", 1432492200, {"service"=>"cpu", "field"=>"softirq", "value"=>27, "hostname"=>"my-host"}],
        ["munin.cpu.steal", 1432492200, {"service"=>"cpu", "field"=>"steal", "value"=>0, "hostname"=>"my-host"}],
        ["munin.cpu.system", 1432492200, {"service"=>"cpu", "field"=>"system", "value"=>507, "hostname"=>"my-host"}],
        ["munin.cpu.user", 1432492200, {"service"=>"cpu", "field"=>"user", "value"=>556, "hostname"=>"my-host"}],
        ["munin.df._dev_sda1", 1432492200, {"service"=>"df", "field"=>"_dev_sda1", "value"=>4.60792528975668, "hostname"=>"my-host"}],
        ["munin.df._run", 1432492200, {"service"=>"df", "field"=>"_run", "value"=>0.685586734693878, "hostname"=>"my-host"}],
        ["munin.df._run_lock", 1432492200, {"service"=>"df", "field"=>"_run_lock", "value"=>0, "hostname"=>"my-host"}],
        ["munin.df._run_shm", 1432492200, {"service"=>"df", "field"=>"_run_shm", "value"=>0, "hostname"=>"my-host"}],
        ["munin.df._run_user", 1432492200, {"service"=>"df", "field"=>"_run_user", "value"=>0, "hostname"=>"my-host"}],
        ["munin.df._sys_fs_cgroup", 1432492200, {"service"=>"df", "field"=>"_sys_fs_cgroup", "value"=>0, "hostname"=>"my-host"}],
        ["munin.df.vagrant", 1432492200, {"service"=>"df", "field"=>"vagrant", "value"=>36.4856735523352, "hostname"=>"my-host"}],
      ]
    end
  end

  context 'when get munin services with tag_prefix' do
    let(:fluentd_conf) do
      default_fluentd_conf.merge(tag_prefix: 'munin2')
    end

    it do
      is_expected.to match_array [
        ["munin2.cpu.guest", 1432492200, {"service"=>"cpu", "field"=>"guest", "value"=>0}],
        ["munin2.cpu.idle", 1432492200, {"service"=>"cpu", "field"=>"idle", "value"=>89532}],
        ["munin2.cpu.iowait", 1432492200, {"service"=>"cpu", "field"=>"iowait", "value"=>37}],
        ["munin2.cpu.irq", 1432492200, {"service"=>"cpu", "field"=>"irq", "value"=>0}],
        ["munin2.cpu.nice", 1432492200, {"service"=>"cpu", "field"=>"nice", "value"=>0}],
        ["munin2.cpu.softirq", 1432492200, {"service"=>"cpu", "field"=>"softirq", "value"=>27}],
        ["munin2.cpu.steal", 1432492200, {"service"=>"cpu", "field"=>"steal", "value"=>0}],
        ["munin2.cpu.system", 1432492200, {"service"=>"cpu", "field"=>"system", "value"=>507}],
        ["munin2.cpu.user", 1432492200, {"service"=>"cpu", "field"=>"user", "value"=>556}],
        ["munin2.df._dev_sda1", 1432492200, {"service"=>"df", "field"=>"_dev_sda1", "value"=>4.60792528975668}],
        ["munin2.df._run", 1432492200, {"service"=>"df", "field"=>"_run", "value"=>0.685586734693878}],
        ["munin2.df._run_lock", 1432492200, {"service"=>"df", "field"=>"_run_lock", "value"=>0}],
        ["munin2.df._run_shm", 1432492200, {"service"=>"df", "field"=>"_run_shm", "value"=>0}],
        ["munin2.df._run_user", 1432492200, {"service"=>"df", "field"=>"_run_user", "value"=>0}],
        ["munin2.df._sys_fs_cgroup", 1432492200, {"service"=>"df", "field"=>"_sys_fs_cgroup", "value"=>0}],
        ["munin2.df.vagrant", 1432492200, {"service"=>"df", "field"=>"vagrant", "value"=>36.4856735523352}],
      ]
    end
  end

  context 'when get munin services as a single record with bulk_suffix' do
    let(:fluentd_conf) do
      default_fluentd_conf.merge(
        bulk: true,
        bulk_suffix: 'metrics2'
      )
    end

    it do
      is_expected.to match_array [
       ["munin.metrics2",
        1432492200,
        {"cpu"=>
          {"user"=>"556",
           "nice"=>"0",
           "system"=>"507",
           "idle"=>"89532",
           "iowait"=>"37",
           "irq"=>"0",
           "softirq"=>"27",
           "steal"=>"0",
           "guest"=>"0"},
         "df"=>
          {"_dev_sda1"=>"4.60792528975668",
           "_sys_fs_cgroup"=>"0",
           "_run"=>"0.685586734693878",
           "_run_lock"=>"0",
           "_run_shm"=>"0",
           "_run_user"=>"0",
           "vagrant"=>"36.4856735523352"}}]]
    end
  end

  context 'when error' do
    let(:error_messages) { [] }

    let(:before_driver_run) do
      allow_any_instance_of(Munin::Node).to receive(:fetch).and_raise('unexpected error')
      allow(driver.instance.log).to receive(:warn) {|msg| error_messages << msg }
    end

    it do
      is_expected.to be_empty
      expect(error_messages).to eq ["cpu: unexpected error", "df: unexpected error"]
    end
  end

  context 'when get munin services with include_service' do
    let(:fluentd_conf) do
      default_fluentd_conf.merge(:include_service => 'cpu')
    end

    it do
      is_expected.to match_array [
        ["munin.cpu.guest", 1432492200, {"service"=>"cpu", "field"=>"guest", "value"=>0}],
        ["munin.cpu.idle", 1432492200, {"service"=>"cpu", "field"=>"idle", "value"=>89532}],
        ["munin.cpu.iowait", 1432492200, {"service"=>"cpu", "field"=>"iowait", "value"=>37}],
        ["munin.cpu.irq", 1432492200, {"service"=>"cpu", "field"=>"irq", "value"=>0}],
        ["munin.cpu.nice", 1432492200, {"service"=>"cpu", "field"=>"nice", "value"=>0}],
        ["munin.cpu.softirq", 1432492200, {"service"=>"cpu", "field"=>"softirq", "value"=>27}],
        ["munin.cpu.steal", 1432492200, {"service"=>"cpu", "field"=>"steal", "value"=>0}],
        ["munin.cpu.system", 1432492200, {"service"=>"cpu", "field"=>"system", "value"=>507}],
        ["munin.cpu.user", 1432492200, {"service"=>"cpu", "field"=>"user", "value"=>556}],
      ]
    end
  end

  context 'when get munin services with exclude_service' do
    let(:fluentd_conf) do
      default_fluentd_conf.merge(exclude_service: 'cpu')
    end

    it do
      is_expected.to match_array [
        ["munin.df._dev_sda1", 1432492200, {"service"=>"df", "field"=>"_dev_sda1", "value"=>4.60792528975668}],
        ["munin.df._run", 1432492200, {"service"=>"df", "field"=>"_run", "value"=>0.685586734693878}],
        ["munin.df._run_lock", 1432492200, {"service"=>"df", "field"=>"_run_lock", "value"=>0}],
        ["munin.df._run_shm", 1432492200, {"service"=>"df", "field"=>"_run_shm", "value"=>0}],
        ["munin.df._run_user", 1432492200, {"service"=>"df", "field"=>"_run_user", "value"=>0}],
        ["munin.df._sys_fs_cgroup", 1432492200, {"service"=>"df", "field"=>"_sys_fs_cgroup", "value"=>0}],
        ["munin.df.vagrant", 1432492200, {"service"=>"df", "field"=>"vagrant", "value"=>36.4856735523352}],
      ]
    end
  end
end
