#
# some fun reading:
#
# https://github.com/puma/puma/blob/master/examples/config.rb
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
#

RAILS_ENV = ENV.fetch('RAILS_ENV', 'development')
if RAILS_ENV == 'production'
  shared_path = '/app/fdga/shared'

  # it's important to set this explicitly, otherwise puma will use the release
  # dir (the target of the symlink) instead of current
  directory '/app/fdga/current'

  # Set the environment in which the rack's app will run. The value must be a string.
  environment 'production'

  # Bind the server to "url". "tcp://", "unix://" and "ssl://" are the only
  # accepted protocols.
  bind "unix://#{shared_path}/tmp/pids/puma.sock"

  # The puma state is used by pumactl.
  state_path "#{shared_path}/tmp/pids/puma.state"

  # Redirect STDOUT and STDERR to files specified. The 3rd parameter
  # ("append") specifies whether the output is appended, the default is
  # "false".
  stdout_redirect "#{shared_path}/log/puma.log", "#{shared_path}/log/puma.err.log", true

  # How many worker processes to run. Typically this is set to to the number of
  # available cores.
  workers Integer(ENV.fetch('PUMA_WORKERS', 2))

  # Configure 'min' to be the minimum number of threads to use to answer
  # requests and 'max' the maximum.
  threads_count = Integer(ENV.fetch('PUMA_THREADS', 5))
  threads threads_count, threads_count

  # Allow workers to reload bundler context when master process is issued a USR1
  # signal. This allows proper reloading of gems while the master is preserved
  # across a phased-restart. (incompatible with preload_app)
  prune_bundler

  # Preload the application before starting the workers
  # amd: must be disabled for phased restarts. otherwise puma silently falls
  # back to regular restarts.
  # preload_app!

  # Worker specific setup for Rails 4.1+
  on_worker_boot do
    # Update with latest /etc/environment. This can prevent config problems
    # caused by Puma deploys not picking up /etc/env updates. This is a best
    # effort so we use a pretty strict regex.
    ENV.update(File.read('/etc/environment').scan(/^([A-Z_]+)=([^#"\s]+)$/).to_h)

    ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
  end
end
