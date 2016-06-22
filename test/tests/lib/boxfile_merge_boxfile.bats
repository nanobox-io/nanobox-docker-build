# source docker helpers
. util/helpers.sh

print_output() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

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
puts JSON.parse(ARGV[0]).deep_symbolize_keys.deep_merge(JSON.parse(ARGV[1]).deep_symbolize_keys).deep_stringify_keys.to_yaml

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/merge_boxfile"
  run docker exec build bash -c "chmod +x /tmp/merge_boxfile"
  run docker exec build bash -c " [ -f /tmp/merge_boxfile ] "

  [ "$status" -eq 0 ]
}

@test "Deep merge child nodes" {
  payload1='{"code.build":{"engine":"engine"}}'
  payload2='{"code.build":{"before_build":["echo hello"]}}'
  
  run docker exec build bash -c "/tmp/merge_boxfile '${payload1}' '${payload2}'"
  
  expected=$(cat <<-END
---
code.build:
  engine: engine
  before_build:
  - echo hello
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Merged boxfile includes nodes from both boxfiles" {
  payload1='{"code.build":{},"web":{}}'
  payload2='{"worker":{},"data":{"image":"nanobox/mysql"}}'
  
  run docker exec build bash -c "/tmp/merge_boxfile '${payload1}' '${payload2}'"
  
  expected=$(cat <<-END
---
code.build: {}
web: {}
worker: {}
data:
  image: nanobox/mysql
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Second boxfile values replace first one" {
  payload1='{"code.build":{"engine":"test"}}'
  payload2='{"code.build":{"engine":"replaced"}}'
  
  run docker exec build bash -c "/tmp/merge_boxfile '${payload1}' '${payload2}'"
  
  expected=$(cat <<-END
---
code.build:
  engine: replaced
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Stop Container" {
  stop_container
}
