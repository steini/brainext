require 'mongrel_cluster/recipes'

set :application, "brainext"
set :domain, "danielsteiner.de"
set :rails_env, "production"
set :default_stage, "production"

set :user, 'steini'

set :ssh_options, {:forward_agent => true}
set :use_sudo, false

default_run_options[:pty] = true

set :scm, "git"
set :branch, "master"
set :repository, "git://github.com/steini/brainext.git"
set :keep_releases, 5
set :git_enable_submodules, 1
set :deploy_via, :remote_cache

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/apps/#{application}"

#set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
set(:mongrel_conf) { "#{current_path}/config/mongrel_cluster.yml" }

role :web, domain
role :app, domain
role :db, domain, :primary => true

task :link_shared_stuff do
  run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
end

after "deploy:symlink", "link_shared_stuff"