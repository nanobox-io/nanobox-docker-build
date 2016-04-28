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
  [ "${lines[18]}" = "    {:transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[19]}" = "     :before_deploy=>" ]
  [ "${lines[20]}" = "      {:type=>:hash," ]
  [ "${lines[21]}" = "       :default=>{}," ]
  [ "${lines[22]}" = "       :template=>" ]
  [ "${lines[23]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[24]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[25]}" = "     :before_deploy_all=>" ]
  [ "${lines[26]}" = "      {:type=>:hash," ]
  [ "${lines[27]}" = "       :default=>{}," ]
  [ "${lines[28]}" = "       :template=>" ]
  [ "${lines[29]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[30]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[31]}" = "     :after_deploy=>" ]
  [ "${lines[32]}" = "      {:type=>:hash," ]
  [ "${lines[33]}" = "       :default=>{}," ]
  [ "${lines[34]}" = "       :template=>" ]
  [ "${lines[35]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[36]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[37]}" = "     :after_deploy_all=>" ]
  [ "${lines[38]}" = "      {:type=>:hash," ]
  [ "${lines[39]}" = "       :default=>{}," ]
  [ "${lines[40]}" = "       :template=>" ]
  [ "${lines[41]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[42]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}}}," ]
  [ "${lines[43]}" = " :dev=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[44]}" = " :\"web.site\"=>" ]
  [ "${lines[45]}" = "  {:type=>:hash," ]
  [ "${lines[46]}" = "   :default=>{}," ]
  [ "${lines[47]}" = "   :template=>" ]
  [ "${lines[48]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[49]}" = "     :start=>{:type=>:string, :default=>nil}," ]
  [ "${lines[50]}" = "     :routes=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[51]}" = "     :ports=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[52]}" = " :\"worker.jobs\"=>" ]
  [ "${lines[53]}" = "  {:type=>:hash," ]
  [ "${lines[54]}" = "   :default=>{}," ]
  [ "${lines[55]}" = "   :template=>" ]
  [ "${lines[56]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[57]}" = "     :start=>{:type=>:string, :default=>nil}}}," ]
  [ "${lines[58]}" = " :\"data.db\"=>" ]
  [ "${lines[59]}" = "  {:type=>:hash," ]
  [ "${lines[60]}" = "   :default=>{}," ]
  [ "${lines[61]}" = "   :template=>" ]
  [ "${lines[62]}" = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[63]}" = "     :image=>{:type=>:string, :default=>nil}}}}" ]
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
  [ "${lines[18]}" = "    {:transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[19]}" = "     :before_deploy=>" ]
  [ "${lines[20]}" = "      {:type=>:hash," ]
  [ "${lines[21]}" = "       :default=>{}," ]
  [ "${lines[22]}" = "       :template=>" ]
  [ "${lines[23]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[24]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[25]}" = "     :before_deploy_all=>" ]
  [ "${lines[26]}" = "      {:type=>:hash," ]
  [ "${lines[27]}" = "       :default=>{}," ]
  [ "${lines[28]}" = "       :template=>" ]
  [ "${lines[29]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[30]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[31]}" = "     :after_deploy=>" ]
  [ "${lines[32]}" = "      {:type=>:hash," ]
  [ "${lines[33]}" = "       :default=>{}," ]
  [ "${lines[34]}" = "       :template=>" ]
  [ "${lines[35]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[36]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[37]}" = "     :after_deploy_all=>" ]
  [ "${lines[38]}" = "      {:type=>:hash," ]
  [ "${lines[39]}" = "       :default=>{}," ]
  [ "${lines[40]}" = "       :template=>" ]
  [ "${lines[41]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[42]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}}}," ]
  [ "${lines[43]}" = " :dev=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[44]}" = " :\"web.site\"=>" ]
  [ "${lines[45]}" = "  {:type=>:hash," ]
  [ "${lines[46]}" = "   :default=>{}," ]
  [ "${lines[47]}" = "   :template=>" ]
  [ "${lines[48]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[49]}" = "     :start=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[50]}" = "     :routes=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[51]}" = "     :ports=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[52]}" = " :\"worker.jobs\"=>" ]
  [ "${lines[53]}" = "  {:type=>:hash," ]
  [ "${lines[54]}" = "   :default=>{}," ]
  [ "${lines[55]}" = "   :template=>" ]
  [ "${lines[56]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[57]}" = "     :start=>{:type=>:hash, :default=>{}}}}," ]
  [ "${lines[58]}" = " :\"data.db\"=>" ]
  [ "${lines[59]}" = "  {:type=>:hash," ]
  [ "${lines[60]}" = "   :default=>{}," ]
  [ "${lines[61]}" = "   :template=>" ]
  [ "${lines[62]}" = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[63]}" = "     :image=>{:type=>:string, :default=>nil}}}}" ]
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
  [ "${lines[18]}" = "    {:transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[19]}" = "     :before_deploy=>" ]
  [ "${lines[20]}" = "      {:type=>:hash," ]
  [ "${lines[21]}" = "       :default=>{}," ]
  [ "${lines[22]}" = "       :template=>" ]
  [ "${lines[23]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[24]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[25]}" = "     :before_deploy_all=>" ]
  [ "${lines[26]}" = "      {:type=>:hash," ]
  [ "${lines[27]}" = "       :default=>{}," ]
  [ "${lines[28]}" = "       :template=>" ]
  [ "${lines[29]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[30]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[31]}" = "     :after_deploy=>" ]
  [ "${lines[32]}" = "      {:type=>:hash," ]
  [ "${lines[33]}" = "       :default=>{}," ]
  [ "${lines[34]}" = "       :template=>" ]
  [ "${lines[35]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[36]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[37]}" = "     :after_deploy_all=>" ]
  [ "${lines[38]}" = "      {:type=>:hash," ]
  [ "${lines[39]}" = "       :default=>{}," ]
  [ "${lines[40]}" = "       :template=>" ]
  [ "${lines[41]}" = "        {:\"web.site\"=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[42]}" = "         :\"worker.jobs\"=>{:type=>:array, :of=>:string, :default=>[]}}}}}," ]
  [ "${lines[43]}" = " :dev=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[44]}" = " :\"web.site\"=>" ]
  [ "${lines[45]}" = "  {:type=>:hash," ]
  [ "${lines[46]}" = "   :default=>{}," ]
  [ "${lines[47]}" = "   :template=>" ]
  [ "${lines[48]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[49]}" = "     :start=>{:type=>:string, :default=>nil}," ]
  [ "${lines[50]}" = "     :routes=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[51]}" = "     :ports=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[52]}" = " :\"worker.jobs\"=>" ]
  [ "${lines[53]}" = "  {:type=>:hash," ]
  [ "${lines[54]}" = "   :default=>{}," ]
  [ "${lines[55]}" = "   :template=>" ]
  [ "${lines[56]}" = "    {:image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[57]}" = "     :start=>{:type=>:hash, :default=>{}}}}," ]
  [ "${lines[58]}" = " :\"data.db\"=>" ]
  [ "${lines[59]}" = "  {:type=>:hash," ]
  [ "${lines[60]}" = "   :default=>{}," ]
  [ "${lines[61]}" = "   :template=>" ]
  [ "${lines[62]}" = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[63]}" = "     :image=>{:type=>:string, :default=>nil}}}}" ]
}

@test "Basic nodes are there" {
  payload='{}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  print_output
  [ "${lines[0]}"   = "{:\"code.build\"=>" ]
  [ "${lines[1]}"   = "  {:type=>:hash," ]
  [ "${lines[2]}"   = "   :default=>{}," ]
  [ "${lines[3]}"   = "   :template=>" ]
  [ "${lines[4]}"   = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[5]}"   = "     :engine=>{:type=>:string, :default=>nil}," ]
  [ "${lines[6]}"   = "     :image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[7]}"   = "     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]}," ]
  [ "${lines[8]}"   = "     :before_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[9]}"   = "     :after_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[10]}"  = "     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[11]}"  = "     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[12]}"  = "     :before_compile=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[13]}"  = "     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[14]}"  = " :\"code.deploy\"=>" ]
  [ "${lines[15]}"  = "  {:type=>:hash," ]
  [ "${lines[16]}"  = "   :default=>{}," ]
  [ "${lines[17]}"  = "   :template=>" ]
  [ "${lines[18]}"  = "    {:transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[19]}"  = "     :before_deploy=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[20]}"  = "     :before_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[21]}"  = "     :after_deploy=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[22]}"  = "     :after_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}}}," ]
  [ "${lines[23]}"  = " :dev=>{:type=>:hash, :default=>{}, :template=>{}}}" ]
}

@test "Filter out bad nodes" {
  payload='{"games":{},"people":{},"books":{},"junk":{}}'
  run docker exec build bash -c "/tmp/template_boxfile '$payload'"
  print_output
  [ "${lines[0]}"   = "{:\"code.build\"=>" ]
  [ "${lines[1]}"   = "  {:type=>:hash," ]
  [ "${lines[2]}"   = "   :default=>{}," ]
  [ "${lines[3]}"   = "   :template=>" ]
  [ "${lines[4]}"   = "    {:config=>{:type=>:hash, :default=>{}}," ]
  [ "${lines[5]}"   = "     :engine=>{:type=>:string, :default=>nil}," ]
  [ "${lines[6]}"   = "     :image=>{:type=>:string, :default=>nil}," ]
  [ "${lines[7]}"   = "     :lib_dirs=>{:type=>:array, :of=>:folders, :default=>[]}," ]
  [ "${lines[8]}"   = "     :before_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[9]}"   = "     :after_setup=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[10]}"  = "     :before_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[11]}"  = "     :after_prepare=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[12]}"  = "     :before_compile=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[13]}"  = "     :after_compile=>{:type=>:array, :of=>:string, :default=>[]}}}," ]
  [ "${lines[14]}"  = " :\"code.deploy\"=>" ]
  [ "${lines[15]}"  = "  {:type=>:hash," ]
  [ "${lines[16]}"  = "   :default=>{}," ]
  [ "${lines[17]}"  = "   :template=>" ]
  [ "${lines[18]}"  = "    {:transform=>{:type=>:array, :of=>:string, :default=>[]}," ]
  [ "${lines[19]}"  = "     :before_deploy=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[20]}"  = "     :before_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[21]}"  = "     :after_deploy=>{:type=>:hash, :default=>{}, :template=>{}}," ]
  [ "${lines[22]}"  = "     :after_deploy_all=>{:type=>:hash, :default=>{}, :template=>{}}}}," ]
  [ "${lines[23]}"  = " :dev=>{:type=>:hash, :default=>{}, :template=>{}}}" ]
}

@test "Stop Container" {
  stop_container
}
