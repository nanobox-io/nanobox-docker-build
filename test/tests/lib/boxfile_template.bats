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
  print_output
  [ "${lines[0]}"  = "{:\"code.build\"=>" ]
  [ "${lines[1]}"  = "  {:type=>:hash," ]
  [ "${lines[2]}"  = "   :default=>{}," ]
  [ "${lines[3]}"  = "   :template=>" ]
  [ "${lines[4]}"  = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[5]}"  = "     :engine=>{:type=>:string, :default=>nil}," ]
  [ "${lines[6]}"  = "     :image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[7]}"  = "     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]}," ]
  [ "${lines[8]}"  = "     :before_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[9]}"  = "     :after_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[10]}" = "     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[11]}" = "     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[12]}" = "     :before_compile=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[13]}" = "     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[14]}" = " :\"code.deploy\"=>" ]
  [ "${lines[15]}" = "  {:type=>:hash," ]
  [ "${lines[16]}" = "   :default=>{}," ]
  [ "${lines[17]}" = "   :template=>" ]
  [ "${lines[18]}" = "    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil}," ]
  [ "${lines[19]}" = "     :transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[20]}" = "     :before_deploy=>" ]
  [ "${lines[21]}" = "      {:type=>:hash," ]
  [ "${lines[22]}" = "       :default=>{}," ]
  [ "${lines[23]}" = "       :template=>" ]
  [ "${lines[24]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[25]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[26]}" = "     :before_deploy_all=>" ]
  [ "${lines[27]}" = "      {:type=>:hash," ]
  [ "${lines[28]}" = "       :default=>{}," ]
  [ "${lines[29]}" = "       :template=>" ]
  [ "${lines[30]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[31]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[32]}" = "     :after_deploy=>" ]
  [ "${lines[33]}" = "      {:type=>:hash," ]
  [ "${lines[34]}" = "       :default=>{}," ]
  [ "${lines[35]}" = "       :template=>" ]
  [ "${lines[36]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[37]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[38]}" = "     :after_deploy_all=>" ]
  [ "${lines[39]}" = "      {:type=>:hash," ]
  [ "${lines[40]}" = "       :default=>{}," ]
  [ "${lines[41]}" = "       :template=>" ]
  [ "${lines[42]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[43]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}}}," ]
  [ "${lines[44]}" = " :dev=>" ]
  [ "${lines[45]}" = "  {:type=>:hash," ]
  [ "${lines[46]}" = "   :default=>{}," ]
  [ "${lines[47]}" = "   :template=>{:cwd=>{:type=>:folder, :default=>nil}}}," ]
  [ "${lines[48]}" = " :\"web.site\"=>" ]
  [ "${lines[49]}" = "  {:type=>:hash," ]
  [ "${lines[50]}" = "   :default=>{}," ]
  [ "${lines[51]}" = "   :template=>" ]
  [ "${lines[52]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[53]}" = "     :start=>{:type=>:string, :default=>nil}," ]
  [ "${lines[54]}" = "     :routes=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[55]}" = "     :ports=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[56]}" = " :\"worker.jobs\"=>" ]
  [ "${lines[57]}" = "  {:type=>:hash," ]
  [ "${lines[58]}" = "   :default=>{}," ]
  [ "${lines[59]}" = "   :template=>" ]
  [ "${lines[60]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[61]}" = "     :start=>{:type=>:string, :default=>nil}}}," ]
  [ "${lines[62]}" = " :\"data.db\"=>" ]
  [ "${lines[63]}" = "  {:type=>:hash," ]
  [ "${lines[64]}" = "   :default=>{}," ]
  [ "${lines[65]}" = "   :template=>" ]
  [ "${lines[66]}" = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[67]}" = "     :image=>{:type=>:string, :default=>nil}}}}" ]
}

@test "test hash start commands" {
  payload='{"code.build":{"config":{"test":"value"}},"web.site":{"start":{"test":"value"}},"worker.jobs":{"start":{"test":"value"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  print_output
  [ "${lines[0]}"  = "{:\"code.build\"=>" ]
  [ "${lines[1]}"  = "  {:type=>:hash," ]
  [ "${lines[2]}"  = "   :default=>{}," ]
  [ "${lines[3]}"  = "   :template=>" ]
  [ "${lines[4]}"  = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[5]}"  = "     :engine=>{:type=>:string, :default=>nil}," ]
  [ "${lines[6]}"  = "     :image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[7]}"  = "     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]}," ]
  [ "${lines[8]}"  = "     :before_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[9]}"  = "     :after_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[10]}" = "     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[11]}" = "     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[12]}" = "     :before_compile=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[13]}" = "     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[14]}" = " :\"code.deploy\"=>" ]
  [ "${lines[15]}" = "  {:type=>:hash," ]
  [ "${lines[16]}" = "   :default=>{}," ]
  [ "${lines[17]}" = "   :template=>" ]
  [ "${lines[18]}" = "    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil}," ]
  [ "${lines[19]}" = "     :transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[20]}" = "     :before_deploy=>" ]
  [ "${lines[21]}" = "      {:type=>:hash," ]
  [ "${lines[22]}" = "       :default=>{}," ]
  [ "${lines[23]}" = "       :template=>" ]
  [ "${lines[24]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[25]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[26]}" = "     :before_deploy_all=>" ]
  [ "${lines[27]}" = "      {:type=>:hash," ]
  [ "${lines[28]}" = "       :default=>{}," ]
  [ "${lines[29]}" = "       :template=>" ]
  [ "${lines[30]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[31]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[32]}" = "     :after_deploy=>" ]
  [ "${lines[33]}" = "      {:type=>:hash," ]
  [ "${lines[34]}" = "       :default=>{}," ]
  [ "${lines[35]}" = "       :template=>" ]
  [ "${lines[36]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[37]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[38]}" = "     :after_deploy_all=>" ]
  [ "${lines[39]}" = "      {:type=>:hash," ]
  [ "${lines[40]}" = "       :default=>{}," ]
  [ "${lines[41]}" = "       :template=>" ]
  [ "${lines[42]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[43]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}}}," ]
  [ "${lines[44]}" = " :dev=>" ]
  [ "${lines[45]}" = "  {:type=>:hash," ]
  [ "${lines[46]}" = "   :default=>{}," ]
  [ "${lines[47]}" = "   :template=>{:cwd=>{:type=>:folder, :default=>nil}}}," ]
  [ "${lines[48]}" = " :\"web.site\"=>" ]
  [ "${lines[49]}" = "  {:type=>:hash," ]
  [ "${lines[50]}" = "   :default=>{}," ]
  [ "${lines[51]}" = "   :template=>" ]
  [ "${lines[52]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[53]}" = "     :start=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[54]}" = "     :routes=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[55]}" = "     :ports=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[56]}" = " :\"worker.jobs\"=>" ]
  [ "${lines[57]}" = "  {:type=>:hash," ]
  [ "${lines[58]}" = "   :default=>{}," ]
  [ "${lines[59]}" = "   :template=>" ]
  [ "${lines[60]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[61]}" = "     :start=>{:type=>:hash, :default=>{}}}}," ]
  [ "${lines[62]}" = " :\"data.db\"=>" ]
  [ "${lines[63]}" = "  {:type=>:hash," ]
  [ "${lines[64]}" = "   :default=>{}," ]
  [ "${lines[65]}" = "   :template=>" ]
  [ "${lines[66]}" = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[67]}" = "     :image=>{:type=>:string, :default=>nil}}}}" ]
}

@test "test string and hash start commands" {
  payload='{"code.build":{"config":{"test":"value"}},"web.site":{"start":"something"},"worker.jobs":{"start":{"test":"value"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  print_output
  [ "${lines[0]}"  = "{:\"code.build\"=>" ]
  [ "${lines[1]}"  = "  {:type=>:hash," ]
  [ "${lines[2]}"  = "   :default=>{}," ]
  [ "${lines[3]}"  = "   :template=>" ]
  [ "${lines[4]}"  = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[5]}"  = "     :engine=>{:type=>:string, :default=>nil}," ]
  [ "${lines[6]}"  = "     :image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[7]}"  = "     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]}," ]
  [ "${lines[8]}"  = "     :before_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[9]}"  = "     :after_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[10]}" = "     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[11]}" = "     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[12]}" = "     :before_compile=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[13]}" = "     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[14]}" = " :\"code.deploy\"=>" ]
  [ "${lines[15]}" = "  {:type=>:hash," ]
  [ "${lines[16]}" = "   :default=>{}," ]
  [ "${lines[17]}" = "   :template=>" ]
  [ "${lines[18]}" = "    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil}," ]
  [ "${lines[19]}" = "     :transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[20]}" = "     :before_deploy=>" ]
  [ "${lines[21]}" = "      {:type=>:hash," ]
  [ "${lines[22]}" = "       :default=>{}," ]
  [ "${lines[23]}" = "       :template=>" ]
  [ "${lines[24]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[25]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[26]}" = "     :before_deploy_all=>" ]
  [ "${lines[27]}" = "      {:type=>:hash," ]
  [ "${lines[28]}" = "       :default=>{}," ]
  [ "${lines[29]}" = "       :template=>" ]
  [ "${lines[30]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[31]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[32]}" = "     :after_deploy=>" ]
  [ "${lines[33]}" = "      {:type=>:hash," ]
  [ "${lines[34]}" = "       :default=>{}," ]
  [ "${lines[35]}" = "       :template=>" ]
  [ "${lines[36]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[37]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[38]}" = "     :after_deploy_all=>" ]
  [ "${lines[39]}" = "      {:type=>:hash," ]
  [ "${lines[40]}" = "       :default=>{}," ]
  [ "${lines[41]}" = "       :template=>" ]
  [ "${lines[42]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[43]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}}}," ]
  [ "${lines[44]}" = " :dev=>" ]
  [ "${lines[45]}" = "  {:type=>:hash," ]
  [ "${lines[46]}" = "   :default=>{}," ]
  [ "${lines[47]}" = "   :template=>{:cwd=>{:type=>:folder, :default=>nil}}}," ]
  [ "${lines[48]}" = " :\"web.site\"=>" ]
  [ "${lines[49]}" = "  {:type=>:hash," ]
  [ "${lines[50]}" = "   :default=>{}," ]
  [ "${lines[51]}" = "   :template=>" ]
  [ "${lines[52]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[53]}" = "     :start=>{:type=>:string, :default=>nil}," ]
  [ "${lines[54]}" = "     :routes=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[55]}" = "     :ports=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[56]}" = " :\"worker.jobs\"=>" ]
  [ "${lines[57]}" = "  {:type=>:hash," ]
  [ "${lines[58]}" = "   :default=>{}," ]
  [ "${lines[59]}" = "   :template=>" ]
  [ "${lines[60]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[61]}" = "     :start=>{:type=>:hash, :default=>{}}}}," ]
  [ "${lines[62]}" = " :\"data.db\"=>" ]
  [ "${lines[63]}" = "  {:type=>:hash," ]
  [ "${lines[64]}" = "   :default=>{}," ]
  [ "${lines[65]}" = "   :template=>" ]
  [ "${lines[66]}" = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[67]}" = "     :image=>{:type=>:string, :default=>nil}}}}" ]
}

@test "Basic nodes are there" {
  payload='{}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  print_output
  [ "${lines[0]}"  = "{:\"code.build\"=>" ]
  [ "${lines[1]}"  = "  {:type=>:hash," ]
  [ "${lines[2]}"  = "   :default=>{}," ]
  [ "${lines[3]}"  = "   :template=>" ]
  [ "${lines[4]}"  = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[5]}"  = "     :engine=>{:type=>:string, :default=>nil}," ]
  [ "${lines[6]}"  = "     :image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[7]}"  = "     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]}," ]
  [ "${lines[8]}"  = "     :before_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[9]}"  = "     :after_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[10]}" = "     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[11]}" = "     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[12]}" = "     :before_compile=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[13]}" = "     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[14]}" = " :\"code.deploy\"=>" ]
  [ "${lines[15]}" = "  {:type=>:hash," ]
  [ "${lines[16]}" = "   :default=>{}," ]
  [ "${lines[17]}" = "   :template=>" ]
  [ "${lines[18]}" = "    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil}," ]
  [ "${lines[19]}" = "     :transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[20]}" = "     :before_deploy=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[21]}" = "     :before_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[22]}" = "     :after_deploy=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[23]}" = "     :after_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}}}," ]
  [ "${lines[24]}" = " :dev=>" ]
  [ "${lines[25]}" = "  {:type=>:hash," ]
  [ "${lines[26]}" = "   :default=>{}," ]
  [ "${lines[27]}" = "   :template=>{:cwd=>{:type=>:folder, :default=>nil}}}}" ]
}

@test "Filter out bad nodes" {
  payload='{"games":{},"people":{},"books":{},"junk":{}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  print_output
  [ "${lines[0]}"  = "{:\"code.build\"=>" ]
  [ "${lines[1]}"  = "  {:type=>:hash," ]
  [ "${lines[2]}"  = "   :default=>{}," ]
  [ "${lines[3]}"  = "   :template=>" ]
  [ "${lines[4]}"  = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[5]}"  = "     :engine=>{:type=>:string, :default=>nil}," ]
  [ "${lines[6]}"  = "     :image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[7]}"  = "     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]}," ]
  [ "${lines[8]}"  = "     :before_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[9]}"  = "     :after_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[10]}" = "     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[11]}" = "     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[12]}" = "     :before_compile=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[13]}" = "     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[14]}" = " :\"code.deploy\"=>" ]
  [ "${lines[15]}" = "  {:type=>:hash," ]
  [ "${lines[16]}" = "   :default=>{}," ]
  [ "${lines[17]}" = "   :template=>" ]
  [ "${lines[18]}" = "    {:deploy_hook_timeout=>{:type=>:integer, :default=>nil}," ]
  [ "${lines[19]}" = "     :transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[20]}" = "     :before_deploy=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[21]}" = "     :before_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[22]}" = "     :after_deploy=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[23]}" = "     :after_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}}}," ]
  [ "${lines[24]}" = " :dev=>" ]
  [ "${lines[25]}" = "  {:type=>:hash," ]
  [ "${lines[26]}" = "   :default=>{}," ]
  [ "${lines[27]}" = "   :template=>{:cwd=>{:type=>:folder, :default=>nil}}}}" ]
}

@test "Stop Container" {
  stop_container
}
