#!/usr/bin/env ruby
require 'socket'

def wait_server_start(host, port)
  600.times do # timeout: 1 min
    begin
      TCPSocket.open(host, port).close
      break
    rescue
      sleep 0.1
    end
  end
end

CPU_CONFIG = <<-EOS
graph_title CPU usage
graph_order system user nice idle iowait irq softirq
graph_args --base 1000 -r --lower-limit 0 --upper-limit 100
graph_vlabel %
graph_scale no
graph_info This graph shows how CPU time is spent.
graph_category system
graph_period second
system.label system
system.draw AREA
system.min 0
system.type DERIVE
system.info CPU time spent by the kernel in system activities
user.label user
user.draw STACK
user.min 0
user.type DERIVE
user.info CPU time spent by normal programs and daemons
nice.label nice
nice.draw STACK
nice.min 0
nice.type DERIVE
nice.info CPU time spent by nice(1)d programs
idle.label idle
idle.draw STACK
idle.min 0
idle.type DERIVE
idle.info Idle CPU time
iowait.label iowait
iowait.draw STACK
iowait.min 0
iowait.type DERIVE
iowait.info CPU time spent waiting for I/O operations to finish when there is nothing else to do.
irq.label irq
irq.draw STACK
irq.min 0
irq.type DERIVE
irq.info CPU time spent handling interrupts
softirq.label softirq
softirq.draw STACK
softirq.min 0
softirq.type DERIVE
softirq.info CPU time spent handling "batched" interrupts
steal.label steal
steal.draw STACK
steal.min 0
steal.type DERIVE
steal.info The time that a virtual CPU had runnable tasks, but the virtual CPU itself was not running
guest.label guest
guest.draw STACK
guest.min 0
guest.type DERIVE
guest.info The time spent running a virtual CPU for guest operating systems under the control of the Linux kernel.
.
EOS

CPU_DATA = <<-EOS
user.value 556
nice.value 0
system.value 507
idle.value 89532
iowait.value 37
irq.value 0
softirq.value 27
steal.value 0
guest.value 0
.
EOS

DF_CONFIG = <<-EOS
graph_title Disk usage in percent
graph_args --upper-limit 100 -l 0
graph_vlabel %
graph_scale no
graph_category disk
_dev_sda1.label /
_dev_sda1.warning 92
_dev_sda1.critical 98
_sys_fs_cgroup.label /sys/fs/cgroup
_sys_fs_cgroup.warning 92
_sys_fs_cgroup.critical 98
_run.label /run
_run.warning 92
_run.critical 98
_run_lock.label /run/lock
_run_lock.warning 92
_run_lock.critical 98
_run_shm.label /run/shm
_run_shm.warning 92
_run_shm.critical 98
_run_user.label /run/user
_run_user.warning 92
_run_user.critical 98
vagrant.label /vagrant
vagrant.warning 92
vagrant.critical 98
.
EOS

DF_DATA = <<-EOS
_dev_sda1.value 4.60792528975668
_sys_fs_cgroup.value 0
_run.value 0.685586734693878
_run_lock.value 0
_run_shm.value 0
_run_user.value 0
vagrant.value 36.4856735523352
.
EOS

def start_munin_node
  Thread.new do
    Socket.tcp_server_loop(NODE_PORT) do |sock, client_addrinfo|
      Thread.new(sock, client_addrinfo.inspect_sockaddr) do |conn, client_info|
        begin
          conn.puts '# munin node at vagrant-ubuntu-trusty-64'

          while cmd = conn.gets
            case cmd.strip
            when 'list'
              conn.puts 'cpu df'
            when /\Aconfig\b(.*)/
              case $1.strip
              when 'cpu'
                conn.puts CPU_CONFIG
              when 'df'
              else
                conn.puts "# Unknown service\n."
              end
            when /\Afetch\b(.*)/
              case $1.strip
              when 'cpu'
                conn.puts CPU_DATA
              when 'df'
                conn.puts DF_DATA
              else
                conn.puts "# Unknown service\n."
              end
            when 'quit'
              conn.close
              break
            else
              conn.puts '# Unknown command. Try list, config, fetch, version or quit'
            end
          end
        ensure
          conn.close unless conn.closed?
        end
      end
    end
  end

  wait_server_start(NODE_HOST, NODE_PORT)
end
