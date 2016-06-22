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
  payload='{"code.build":{"config":{"test":"value"}},"web.site":{"start":"something"},"worker.jobs":{"start":"something"},"data.db":{"image":"nanobox/mysql"}}'
  
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"code.build"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :dev_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :before_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :after_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :before_compile=>{:type=>:array, :of=>:string, :default=>[]},
     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"code.deploy"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_deploy=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :before_deploy_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_deploy=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_deploy_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}}}},
 :dev=>
  {:type=>:hash,
   :default=>{},
   :template=>{:cwd=>{:type=>:folder, :default=>nil}}},
 :"web.site"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:string, :default=>nil},
     :routes=>{:type=>:array, :of=>:string, :default=>[]},
     :ports=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"worker.jobs"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:string, :default=>nil}}},
 :"data.db"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :image=>{:type=>:string, :default=>nil}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test hash start commands" {
  payload='{"code.build":{"config":{"test":"value"}},"web.site":{"start":{"test":"value"}},"worker.jobs":{"start":{"test":"value"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"code.build"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :dev_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :before_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :after_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :before_compile=>{:type=>:array, :of=>:string, :default=>[]},
     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"code.deploy"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_deploy=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :before_deploy_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_deploy=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_deploy_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}}}},
 :dev=>
  {:type=>:hash,
   :default=>{},
   :template=>{:cwd=>{:type=>:folder, :default=>nil}}},
 :"web.site"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:hash, :default=>{}},
     :routes=>{:type=>:array, :of=>:string, :default=>[]},
     :ports=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"worker.jobs"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:hash, :default=>{}}}},
 :"data.db"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :image=>{:type=>:string, :default=>nil}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "test string and hash start commands" {
  payload='{"code.build":{"config":{"test":"value"}},"web.site":{"start":"something"},"worker.jobs":{"start":{"test":"value"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"code.build"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :dev_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :before_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :after_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :before_compile=>{:type=>:array, :of=>:string, :default=>[]},
     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"code.deploy"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_deploy=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :before_deploy_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_deploy=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}},
     :after_deploy_all=>
      {:type=>:hash,
       :default=>{},
       :template=>
        {:"web.site"=>{:type=>:array, :of=>:string, :default=>[]},
         :"worker.jobs"=>{:type=>:array, :of=>:string, :default=>[]}}}}},
 :dev=>
  {:type=>:hash,
   :default=>{},
   :template=>{:cwd=>{:type=>:folder, :default=>nil}}},
 :"web.site"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:string, :default=>nil},
     :routes=>{:type=>:array, :of=>:string, :default=>[]},
     :ports=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"worker.jobs"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:image=>{:type=>:string, :default=>nil},
     :start=>{:type=>:hash, :default=>{}}}},
 :"data.db"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :image=>{:type=>:string, :default=>nil}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Basic nodes are there" {
  payload='{}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"code.build"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :dev_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :before_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :after_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :before_compile=>{:type=>:array, :of=>:string, :default=>[]},
     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"code.deploy"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_deploy=>{:type=>:hash, :default=>{}, :template=>{}},
     :before_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}},
     :after_deploy=>{:type=>:hash, :default=>{}, :template=>{}},
     :after_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}}},
 :dev=>
  {:type=>:hash,
   :default=>{},
   :template=>{:cwd=>{:type=>:folder, :default=>nil}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Filter out bad nodes" {
  payload='{"games":{},"people":{},"books":{},"junk":{}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  
  expected=$(cat <<-END
{:"code.build"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:config=>{:type=>:hash, :default=>{}},
     :engine=>{:type=>:string, :default=>nil},
     :image=>{:type=>:string, :default=>nil},
     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]},
     :extra_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :dev_packages=>{:type=>:array, :of=>:strings, :default=>nil},
     :before_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :after_setup=>{:type=>:array, :of=>:string, :default=>[]},
     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]},
     :before_compile=>{:type=>:array, :of=>:string, :default=>[]},
     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}},
 :"code.deploy"=>
  {:type=>:hash,
   :default=>{},
   :template=>
    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil},
     :transform=>{:type=>:array, :of=>:string, :default=>[]},
     :before_deploy=>{:type=>:hash, :default=>{}, :template=>{}},
     :before_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}},
     :after_deploy=>{:type=>:hash, :default=>{}, :template=>{}},
     :after_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}}},
 :dev=>
  {:type=>:hash,
   :default=>{},
   :template=>{:cwd=>{:type=>:folder, :default=>nil}}}}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Stop Container" {
  stop_container
}
