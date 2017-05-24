# source docker helpers
. util/helpers.sh

@test "Start Container" {
  start_container
}

@test "Create commitish test script" {
  script="$(cat <<-END
#!/usr/bin/env ruby

$:.unshift  '/opt/gonano/hookit/vendor/bundle'
require 'bundler/setup'

# load hookit/setup to bootstrap hookit and import the dsl
require 'hookit/setup'

require 'json'
require 'yaml'
require 'pp'
require '/opt/nanobox/hooks/lib/boxfile.rb'
require '/opt/nanobox/hooks/lib/hash.rb'

include Nanobox::Boxfile

# Just echo the url type
pp template_boxfile(JSON.parse(ARGV.first).deep_symbolize_keys)

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/template_boxfile"
  run docker exec build bash -c "chmod +x /tmp/template_boxfile"
  run docker exec build bash -c " [ -f /tmp/template_boxfile ] "

  [ "$status" -eq 0 ]
}

@test "test string start commands" {
  payload='{"run.config":{"config":{"test":"value"}},"web.site":{"start":"something"},"worker.jobs":{"start":"something"},"data.db":{"image":"nanobox/mysql"}}'
  
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"run.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:"engine.config"=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :cache_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :dev_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :cwd=>{:type=>:folder, :default=>nil},
     :fs_watch=>{:type=>:on_off, :default=>nil},
     :build_triggers=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"deploy.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_live=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :before_live_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_live=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_live_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}}}},
 :"web.site"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:string, :default=>nil},
     :routes=>{:type=>:array, :of=>:string, :default=>[]},
     :ports=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_files=>{:type=>:array, :of=>:string, :default=>[]},
     :network_dirs=>{:type=>:hash, :default=>{}},
     :log_watch=>{:type=>:hash, :default=>{}},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}},
 :"worker.jobs"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:string, :default=>nil},
     :writable_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_files=>{:type=>:array, :of=>:string, :default=>[]},
     :network_dirs=>{:type=>:hash, :default=>{}},
     :log_watch=>{:type=>:hash, :default=>{}},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}},
 :"data.db"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :image=>{:type=>:string, :default=>nil},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test string array start commands" {
  payload='{"run.config":{"config":{"test":"value"}},"web.site":{"start":["something", "something2"]},"worker.jobs":{"start":"something"},"data.db":{"image":"nanobox/mysql"}}'
  
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"run.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:"engine.config"=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :cache_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :dev_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :cwd=>{:type=>:folder, :default=>nil},
     :fs_watch=>{:type=>:on_off, :default=>nil},
     :build_triggers=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"deploy.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_live=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :before_live_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_live=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_live_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}}}},
 :"web.site"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:array, :of=>:string, :default=>[]},
     :routes=>{:type=>:array, :of=>:string, :default=>[]},
     :ports=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_files=>{:type=>:array, :of=>:string, :default=>[]},
     :network_dirs=>{:type=>:hash, :default=>{}},
     :log_watch=>{:type=>:hash, :default=>{}},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}},
 :"worker.jobs"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:string, :default=>nil},
     :writable_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_files=>{:type=>:array, :of=>:string, :default=>[]},
     :network_dirs=>{:type=>:hash, :default=>{}},
     :log_watch=>{:type=>:hash, :default=>{}},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}},
 :"data.db"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :image=>{:type=>:string, :default=>nil},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test hash start commands" {
  payload='{"run.config":{"config":{"test":"value"}},"web.site":{"start":{"test":"value"}},"worker.jobs":{"start":{"test":"value"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"run.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:"engine.config"=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :cache_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :dev_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :cwd=>{:type=>:folder, :default=>nil},
     :fs_watch=>{:type=>:on_off, :default=>nil},
     :build_triggers=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"deploy.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_live=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :before_live_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_live=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_live_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}}}},
 :"web.site"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:hash, :default=>{}},
     :routes=>{:type=>:array, :of=>:string, :default=>[]},
     :ports=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_files=>{:type=>:array, :of=>:string, :default=>[]},
     :network_dirs=>{:type=>:hash, :default=>{}},
     :log_watch=>{:type=>:hash, :default=>{}},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}},
 :"worker.jobs"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:hash, :default=>{}},
     :writable_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_files=>{:type=>:array, :of=>:string, :default=>[]},
     :network_dirs=>{:type=>:hash, :default=>{}},
     :log_watch=>{:type=>:hash, :default=>{}},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}},
 :"data.db"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :image=>{:type=>:string, :default=>nil},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test string and hash start commands" {
  payload='{"run.config":{"config":{"test":"value"}},"web.site":{"start":"something"},"worker.jobs":{"start":{"test":"value"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"run.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:"engine.config"=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :cache_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :dev_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :cwd=>{:type=>:folder, :default=>nil},
     :fs_watch=>{:type=>:on_off, :default=>nil},
     :build_triggers=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"deploy.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_live=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :before_live_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_live=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_live_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}}}},
 :"web.site"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:string, :default=>nil},
     :routes=>{:type=>:array, :of=>:string, :default=>[]},
     :ports=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_files=>{:type=>:array, :of=>:string, :default=>[]},
     :network_dirs=>{:type=>:hash, :default=>{}},
     :log_watch=>{:type=>:hash, :default=>{}},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}},
 :"worker.jobs"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:hash, :default=>{}},
     :writable_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :writable_files=>{:type=>:array, :of=>:string, :default=>[]},
     :network_dirs=>{:type=>:hash, :default=>{}},
     :log_watch=>{:type=>:hash, :default=>{}},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}},
 :"data.db"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :image=>{:type=>:string, :default=>nil},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :local_only=>{:type=>:on_off, :default=>nil},
     :cron=>
      {:type=>:array,
       :of=>:hash,
       :default=>[],
       :template=>
        {:id=>{:type=>:string, :default=>nil},
         :schedule=>{:type=>:string, :default=>nil},
         :command=>{:type=>:string, :default=>nil}}}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Basic nodes are there" {
  payload='{}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"run.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:"engine.config"=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :cache_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :dev_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :cwd=>{:type=>:folder, :default=>nil},
     :fs_watch=>{:type=>:on_off, :default=>nil},
     :build_triggers=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"deploy.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_live=>{:type=>:hash, :default=>{}, :template=>{}},
     :before_live_all=>{:type=>:hash, :default=>{}, :template=>{}},
     :after_live=>{:type=>:hash, :default=>{}, :template=>{}},
     :after_live_all=>{:type=>:hash, :default=>{}, :template=>{}}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Filter out bad nodes" {
  payload='{"games":{},"people":{},"books":{},"junk":{}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"run.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:"engine.config"=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :cache_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :dev_packages=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_path_dirs=>{:type=>:array, :of=>:string, :default=>[]},
     :extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :cwd=>{:type=>:folder, :default=>nil},
     :fs_watch=>{:type=>:on_off, :default=>nil},
     :build_triggers=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"deploy.config"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:extra_steps=>{:type=>:array, :of=>:string, :default=>[]},
     :deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_live=>{:type=>:hash, :default=>{}, :template=>{}},
     :before_live_all=>{:type=>:hash, :default=>{}, :template=>{}},
     :after_live=>{:type=>:hash, :default=>{}, :template=>{}},
     :after_live_all=>{:type=>:hash, :default=>{}, :template=>{}}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Stop Container" {
  stop_container
}
