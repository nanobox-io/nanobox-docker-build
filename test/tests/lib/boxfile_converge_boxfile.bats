# source docker helpers
. util/docker.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

@test "Start Container" {
  start_container "test-converge_boxfile" "192.168.0.2"
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

include Nanobox::Boxfile

# Just echo the url type
puts converge_boxfile(JSON.parse(ARGV.first).deep_symbolize_keys).prune_empty.deep_stringify_keys.to_yaml

END
)"

  run docker exec test-converge_boxfile bash -c "echo \"${script}\" > /tmp/converge_boxfile"
  run docker exec test-converge_boxfile bash -c "chmod +x /tmp/converge_boxfile"
  run docker exec test-converge_boxfile bash -c " [ -f /tmp/converge_boxfile ] "

  [ "$status" -eq 0 ]
}

@test "Converge using basic names for services" {
  payload='{"code.build":{},"web":{},"worker":{},"data":{"image":"nanobox/mysql"}}'
  run docker exec test-converge_boxfile bash -c "/tmp/converge_boxfile '$payload'"
  echo_lines
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "code.build:" ]
  [ "${lines[2]}" = "  image: nanobox/build" ]
  [ "${lines[3]}" = "web:" ]
  [ "${lines[4]}" = "  image: nanobox/code" ]
  [ "${lines[5]}" = "worker:" ]
  [ "${lines[6]}" = "  image: nanobox/code" ]
  [ "${lines[7]}" = "data:" ]
  [ "${lines[8]}" = "  image: nanobox/mysql" ]
}

@test "Converge using complex names for services" {
  payload='{"code.build":{},"web.site":{},"worker.jobs":{},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec test-converge_boxfile bash -c "/tmp/converge_boxfile '$payload'"
  echo_lines
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

@test "Filter out bad nodes" {
  payload='{"games":{},"people":{},"books":{},"junk":{}}'
  run docker exec test-converge_boxfile bash -c "/tmp/converge_boxfile '$payload'"
  echo_lines
  [ "$output" = "--- {}" ]
}

@test "Stop Container" {
  stop_container "test-converge_boxfile"
}
