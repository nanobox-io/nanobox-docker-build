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
boxfile = JSON.parse(ARGV.first).deep_symbolize_keys
puts converge_boxfile(boxfile).prune_empty.deep_stringify_keys.to_yaml

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/converge_boxfile"
  run docker exec build bash -c "chmod +x /tmp/converge_boxfile"
  run docker exec build bash -c " [ -f /tmp/converge_boxfile ] "

  [ "$status" -eq 0 ]
}

@test "Test string start commands" {
  payload='{"code.build":{},"web.site":{"start":"something"},"worker.jobs":{"start":"something"},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  print_output
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "web.site:" ]
  [ "${lines[2]}" = "  start: something" ]
  [ "${lines[3]}" = "worker.jobs:" ]
  [ "${lines[4]}" = "  start: something" ]
  [ "${lines[5]}" = "data.db:" ]
  [ "${lines[6]}" = "  image: nanobox/mysql" ]
}

@test "Test hash start commands" {
  payload='{"code.build":{},"web.site":{"start":{"worker":"something"}},"worker.jobs":{"start":{"worker":"something"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  print_output
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "web.site:" ]
  [ "${lines[2]}" = "  start:" ]
  [ "${lines[3]}" = "    worker: something" ]
  [ "${lines[4]}" = "worker.jobs:" ]
  [ "${lines[5]}" = "  start:" ]
  [ "${lines[6]}" = "    worker: something" ]
  [ "${lines[7]}" = "data.db:" ]
  [ "${lines[8]}" = "  image: nanobox/mysql" ]
}

@test "Test string and hash start commands" {
  payload='{"code.build":{},"web.site":{"start":"something"},"worker.jobs":{"start":{"worker":"something"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  print_output
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "web.site:" ]
  [ "${lines[2]}" = "  start: something" ]
  [ "${lines[3]}" = "worker.jobs:" ]
  [ "${lines[4]}" = "  start:" ]
  [ "${lines[5]}" = "    worker: something" ]
  [ "${lines[6]}" = "data.db:" ]
  [ "${lines[7]}" = "  image: nanobox/mysql" ]
}

@test "Converge using complex names for services" {
  payload='{"code.deploy":{"before_deploy":{"web.site":["echo hi"]}},"web.site":{},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  print_output
  [ "${lines[0]}"  = "---" ]
  [ "${lines[1]}"  = "code.deploy:" ]
  [ "${lines[2]}"  = "  before_deploy:" ]
  [ "${lines[3]}"  = "    web.site:" ]
  [ "${lines[4]}"  = "    - echo hi" ]
  [ "${lines[5]}" = "data.db:" ]
  [ "${lines[6]}" = "  image: nanobox/mysql" ]
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
