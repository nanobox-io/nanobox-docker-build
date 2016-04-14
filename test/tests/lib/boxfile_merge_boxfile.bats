# source docker helpers
. util/docker.sh

echo_lines() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

@test "Start Container" {
  start_container "test-merge_boxfile" "192.168.0.2"
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
puts merge_boxfile(JSON.parse(ARGV[0]).deep_symbolize_keys, JSON.parse(ARGV[1]).deep_symbolize_keys).deep_stringify_keys.to_yaml

END
)"

  run docker exec test-merge_boxfile bash -c "echo \"${script}\" > /tmp/merge_boxfile"
  run docker exec test-merge_boxfile bash -c "chmod +x /tmp/merge_boxfile"
  run docker exec test-merge_boxfile bash -c " [ -f /tmp/merge_boxfile ] "

  [ "$status" -eq 0 ]
}

@test "Deep merge child nodes" {
  payload1='{"code.build":{"engine":"engine"}}'
  payload2='{"code.build":{"before_build":["echo hello"]}}'
  run docker exec test-merge_boxfile bash -c "/tmp/merge_boxfile '${payload1}' '${payload2}'"
  echo_lines
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "code.build:" ]
  [ "${lines[2]}" = "  engine: engine" ]
  [ "${lines[3]}" = "  before_build:" ]
  [ "${lines[4]}" = "  - echo hello" ]

}

@test "Merged boxfile includes nodes from both boxfiles" {
  payload1='{"code.build":{},"web":{}}'
  payload2='{"worker":{},"data":{"image":"nanobox/mysql"}}'
  run docker exec test-merge_boxfile bash -c "/tmp/merge_boxfile '${payload1}' '${payload2}'"
  echo_lines
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "code.build: {}" ]
  [ "${lines[2]}" = "web: {}" ]
  [ "${lines[3]}" = "worker: {}" ]
  [ "${lines[4]}" = "data:" ]
  [ "${lines[5]}" = "  image: nanobox/mysql" ]

}

@test "Second boxfile values replace first one" {
  payload1='{"code.build":{"engine":"test"}}'
  payload2='{"code.build":{"engine":"replaced"}}'
  run docker exec test-merge_boxfile bash -c "/tmp/merge_boxfile '${payload1}' '${payload2}'"
  echo_lines
  [ "${lines[0]}" = "---" ]
  [ "${lines[1]}" = "code.build:" ]
  [ "${lines[2]}" = "  engine: replaced" ]

}

@test "Stop Container" {
  stop_container "test-merge_boxfile"
}
