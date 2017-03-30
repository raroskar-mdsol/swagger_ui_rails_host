# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 10 threads for minimum
# and maximum, this matches the default thread size of Active Record.
#
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 10 }.to_i
threads threads_count, threads_count * 2

# Specifies the `port` that Puma will listen on to receive requests, default is 3000.
#
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch("RAILS_ENV") { "development" }

# Store the pid of the server in the file at "path".
#
system "mkdir -p #{Rails.root}/pids" unless Dir.exists? File.join(Rails.root, 'pids')
pidfile 'pids/puma.pid'

# Redirect STDOUT and STDERR to files specified. The 3rd parameter
# ("append") specifies whether the output is appended, the default is
# "false".
#
# stdout_redirect '/u/apps/lolcat/log/stdout', '/u/apps/lolcat/log/stderr'
# stdout_redirect '/u/apps/lolcat/log/stdout', '/u/apps/lolcat/log/stderr', true
# see https://github.com/puma/puma/issues/966#issuecomment-237379966
stdout_redirect 'log/puma_stdout.log', 'log/puma_stderr.log', true

# The code in the `on_worker_boot` will be called if you are using
# clustered mode by specifying a number of `workers`. After each worker
# process is booted this block will be run, if you are using `preload_app!`
# option you will want to use this block to reconnect to any threads
# or connections that may have been created at application boot, Ruby
# cannot share connections between processes.
#
# on_worker_boot do
#   ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
# end

if ENV['RAILS_ENV'] == 'production'
  # === Cluster mode ===

  # How many worker processes to run.  Typically this is set to
  # to the number of available cores.
  # Ref: https://github.com/puma/puma/blob/master/DEPLOYMENT.md#single-vs-cluster-mode
  #
  # The default is "0".
  #
  workers ENV.fetch("PUMA_WORKERS") { 2 } if ENV['RAILS_ENV'] == 'production'

  # Code to run immediately before the master starts workers.
  #
  # TODO: uncomment when backed by database
  # before_fork do
  #   ActiveRecord::Base.connection_pool.disconnect!
  # end

  # Code to run in a worker before it starts serving requests.
  #
  # This is called every time a worker is to be started.
  #
  # TODO: uncomment when backed by database
  # on_worker_boot do
  #   ActiveSupport.on_load(:active_record) do
  #     ActiveRecord::Base.establish_connection
  #   end
  # end

  # Code to run in the master right before a worker is started. The worker's
  # index is passed as an argument.
  #
  # This is called every time a worker is to be started.
  #
  on_worker_fork do
    Rails.logger.info "A new Puma worker has started"
    master = ObjectSpace.each_object(Puma::Cluster).first if defined?(Puma::Cluster)
    workers = master&.instance_variable_get(:@workers)
    dead_worker_indexes = workers ? ((0...@options[:workers]).to_a - workers.map(&:index)) : []

    dead_worker_indexes.each do |dead_worker_index|
      list_puma_processes_cmd = "ps -ef | grep -E 'puma: cluster worker [#{dead_worker_index}]' | grep -v grep"
      list_puma_processes_cmd_result = `#{list_puma_processes_cmd}`.split("\n")
      Rails.logger.info "Currently running processes info: #{list_puma_processes_cmd_result}"
      pids = `#{list_puma_processes_cmd} | awk '{print $2;}'`.split("\n")
      Rails.logger.info "Pids of currently running processes: #{pids.inspect}"
      pids.each do |pid|
        Rails.logger.warn "sending KILL to puma cluster worker process #{pid}"
        Rails.logger.warn `kill -s KILL #{pid}`
      end
    end
  end

  # Use the `preload_app!` method when specifying a `workers` number.
  # This directive tells Puma to first boot the application and load code
  # before forking the application. This takes advantage of Copy On Write
  # process behavior so workers use less memory. If you use this option
  # you need to make sure to reconnect any threads in the `on_worker_boot`
  # block.
  #

  preload_app!

  # see https://github.com/puma/puma/commit/448c022
  force_shutdown_after 5
end


# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
