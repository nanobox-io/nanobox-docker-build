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
require '/opt/nanobox/hooks/lib/boxfile.rb'
require '/opt/nanobox/hooks/lib/hash.rb'

include Nanobox::Boxfile

# Just echo the url type
puts converge_boxfile(JSON.parse(ARGV.first).deep_symbolize_keys).prune_empty.deep_stringify_keys.to_yaml

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/converge_boxfile"
  run docker exec build bash -c "chmod +x /tmp/converge_boxfile"
  run docker exec build bash -c " [ -f /tmp/converge_boxfile ] "

  [ "$status" -eq 0 ]
}

@test "Converge using complex names for services" {
  payload='{"code.build":{},"web.site":{},"worker.jobs":{},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  print_output
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "code.build:" ]
  [ "${lines[2]}" = "  image: nanobox/build" ]
  [ "${lines[3]}" = "web.site:" ]
  [ "${lines[4]}" = "  image: nanobox/code" ]
  [ "${lines[5]}" = "worker.jobs:" ]
  [ "${lines[6]}" = "  image: nanobox/code" ]
  [ "${lines[7]}" = "data.db:" ]
  [ "${lines[8]}" = "  image: nanobox/mysql" ]
}

@test "Converge using complex names for services" {
  payload='{"code.build":{},"code.deploy":{"before_deploy":{"web.site":["echo hi"]}},"web.site":{},"worker.jobs":{},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  print_output
  [ "${lines[0]}"  = "---" ]
  [ "${lines[1]}"  = "code.build:" ]
  [ "${lines[2]}"  = "  image: nanobox/build" ]
  [ "${lines[3]}"  = "code.deploy:" ]
  [ "${lines[4]}"  = "  before_deploy:" ]
  [ "${lines[5]}"  = "    web.site:" ]
  [ "${lines[6]}"  = "    - echo hi" ]
  [ "${lines[7]}"  = "web.site:" ]
  [ "${lines[8]}"  = "  image: nanobox/code" ]
  [ "${lines[9]}"  = "worker.jobs:" ]
  [ "${lines[10]}" = "  image: nanobox/code" ]
  [ "${lines[11]}" = "data.db:" ]
  [ "${lines[12]}" = "  image: nanobox/mysql" ]
}

@test "Filter out bad nodes" {
  payload='{"games":{},"people":{},"books":{},"junk":{}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  print_output
  [ "$output" = "--- {}" ]
}

@test "Stop Container" {
  stop_container
}
