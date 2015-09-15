require 'fluent_plugin_munin_node/version'

class Fluent::MuninNodeInput < Fluent::Input
  Fluent::Plugin.register_input('munin_node', self)

  unless method_defined?(:log)
    define_method('log') { $log }
  end

  unless method_defined?(:router)
    define_method('router') { Fluent::Engine }
  end

  config_param :node_host,       :string,  :default => '127.0.0.1'
  config_param :node_port,       :integer, :default => 4949
  config_param :interval,        :time,    :default => 60
  config_param :tag_prefix,      :string,  :default => 'munin'
  config_param :bulk_suffix,     :string,  :default => 'metrics'
  config_param :service_key,     :string,  :default => 'service'
  config_param :field_key,       :string,  :default => 'field'
  config_param :value_key,       :string,  :default => 'value'
  config_param :extra,           :hash,    :default => {}
  config_param :bulk,            :bool,    :default => false
  config_param :include_service, :string,  :default => nil
  config_param :exclude_service, :string,  :default => nil

  def initialize
    super
    require 'munin-ruby'
  end

  def configure(conf)
    super

    @include_service = Regexp.new(@include_service) if @include_service
    @exclude_service = Regexp.new(@exclude_service) if @exclude_service
  end

  def start
    super

    @loop = Coolio::Loop.new
    timer = TimerWatcher.new(@interval, true, log, &method(:fetch_items))
    @loop.attach(timer)
    @thread = Thread.new(&method(:run))
  end

  def shutdown
    @loop.watchers.each(&:detach)
    @loop.stop

    # XXX: Comment out for exit quickly. Is it OK?
    #@thread.join
  end

  private

  def run
    @loop.run
  rescue => e
    log.error(e.message)
    log.error_backtrace(e.backtrace)
  end

  def fetch_items
    values_by_service = {}

    # It connect to Munin node every time.
    node = Munin::Node.new(@node_host, @node_port)
    services = filter_service(node.list)

    services.each do |service|
      begin
        service_values = node.fetch(service)
        values_by_service.update(service_values)
      rescue => e
        log.warn("#{service}: #{e.message}")
        log.warn_backtrace(e.backtrace)
      end
    end

    emit_items(values_by_service)
  end

  def emit_items(values_by_service)
    if @bulk
      tag = @tag_prefix + '.' + @bulk_suffix
      router.emit(tag, Fluent::Engine.now, values_by_service.merge(extra))
    else
      values_by_service.each do |service, value_by_field|
        value_by_field.each do |fieldname, value|
          tag = [@tag_prefix, service, fieldname].join('.')

          record = {
            @service_key => service,
            @field_key => fieldname,
            @value_key => value =~ /\./ ? value.to_f : value.to_i,
          }

          router.emit(tag, Fluent::Engine.now, record.merge(extra))
        end
      end
    end
  end

  def filter_service(services)
    if @exclude_service
      services = services.reject do |srvc|
        srvc =~ @exclude_service
      end
    end

    if @include_service
      services = services.select do |srvc|
        srvc =~ @include_service
      end
    end

    services
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
