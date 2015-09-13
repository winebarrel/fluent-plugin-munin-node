require 'fluent_plugin_munin_node/version'

class Fluent::MuninNodeInput < Fluent::Input
  Fluent::Plugin.register_input('munin_node', self)

  unless method_defined?(:log)
    define_method('log') { $log }
  end

  unless method_defined?(:router)
    define_method('router') { Fluent::Engine }
  end

  config_param :node_host,            :string,  :default => '127.0.0.1'
  config_param :node_port,            :integer, :default => 4949
  config_param :interval,             :time,    :default => 60
  config_param :tag,                  :string,  :default => 'munin.item'
  config_param :plugin_key,           :string,  :default => 'plugin'
  config_param :datasource_key,       :string,  :default => 'datasource'
  config_param :datasource_value_key, :string,  :default => 'value'
  config_param :extra,                :hash,    :default => {}
  config_param :bulk,                 :bool,    :default => false

  def initialize
    super
    require 'munin-ruby'
  end

  def configure(conf)
    super
  end

  def start
    super

    @node = Munin::Node.new(@node_host, @node_port)
    @loop = Coolio::Loop.new
    timer = TimerWatcher.new(@interval, true, log, &method(:fetch_items))
    @loop.attach(timer)
    @thread = Thread.new(&method(:run))
  end

  def shutdown
    @loop.watchers.each(&:detach)
    @loop.stop

    # XXX: Comment out for exit soon. Is it OK?
    #@thread.join

    @node.disconnect
    @node.connection.close
  end

  private

  def run
    @loop.run
  rescue => e
    log.error(e.message)
    log.error_backtrace(e.backtrace)
  end

  def fetch_items
    values_by_plugin = {}

    @node.list.each do |plugin|
      begin
        plugin_values = @node.fetch(plugin)
        values_by_plugin.update(plugin_values)
      rescue => e
        log.warn("#{plugin}: #{e.message}")
        log.warn_backtrace(e.backtrace)
      end
    end

    emit_items(values_by_plugin)
  end

  def emit_items(values_by_plugin)
    time = Time.now

    if @bulk
      router.emit(@tag, time.to_i, values_by_plugin.merge(extra))
    else
      values_by_plugin.each do |plugin, value_by_datasource|
        value_by_datasource.each do |datasource, value|
          record = {
            @plugin_key => plugin,
            @datasource_key => datasource,
            @datasource_value_key => value,
          }

          router.emit(@tag, time.to_i, record.merge(extra))
        end
      end
    end
  end

  class TimerWatcher < Coolio::TimerWatcher
    def initialize(interval, repeat, log, &callback)
      @callback = callback
      @log = log
      super(interval, repeat)
    end

    def on_timer
      @callback.call
    rescue => e
      @log.error(e.message)
      @log.error_backtrace(e.backtrace)
    end
  end # TimerWatcher
end # Fluent::MuninNodeInput
