# source docker helpers
. util/helpers.sh

@test "Start Container" {
  start_container
}

@test "Create validation test script" {
  script="$(cat <<-END
#!/usr/bin/env ruby

$:.unshift  '/opt/gonano/hookit/vendor/bundle'
require 'bundler/setup'

# load hookit/setup to bootstrap hookit and import the dsl
require 'hookit/setup'

require 'json'
require 'yaml'
require 'ya2yaml'
require '/opt/nanobox/hooks/lib/boxfile.rb'
require '/opt/nanobox/hooks/lib/hash.rb'

include Nanobox::Boxfile

boxfile = YAML::load(ARGV[1]).deep_symbolize_keys
puts validate_boxfile(boxfile)
  .deep_stringify_keys
  .ya2yaml(:syck_compatible => true)

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/validate_boxfile"
  run docker exec build bash -c "chmod +x /tmp/validate_boxfile"
  run docker exec build bash -c " [ -f /tmp/validate_boxfile ] "

  [ "$status" -eq 0 ]
}

@test "Should be empty when there aren't errors" {
  payload=$(cat <<-END
code.build:
  engine: ruby
END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"

  echo "$output"

  [ "$output" = "--- {}" ]
}

@test "Should require an engine" {
  payload=$(cat <<-END
code.build:
  config: {}
END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"

  expected=$(cat <<-END
--- 
code.build: 
  engine: "Cannot be empty"
END
)

  echo "$output"

  [ "$output" = "$expected" ]
}

@test "Should enforce proper types" {
  payload=$(cat <<-END
code.build:
  engine: 1
  
web.main:
  start: {}
  log_watch: ok
END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"

  expected=$(cat <<-END
--- 
code.build: 
  engine: "Must be a string"
web.main: 
  log_watch: "Must be a hash"
  start: "Must be a string or an array of strings"
END
)

  echo "$output"

  [ "$output" = "$expected" ]
}

@test "Ensures writable dirs reference actual components" {
  payload=$(cat <<-END
code.build:
    engine: ruby
    
web.main:
  start: bash
  network_dirs:
    nope:
      - /foo/bar
    data.files:
      - /foo/bar
    worker.main:
      - /foo/bar
    
worker.main:
  start: bash

data.files:
  image: nanobox/gluster

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"

  expected=$(cat <<-END
--- 
web.main: 
  network_dirs: 
    nope: "nope is not a valid data node"
    worker.main: "worker.main is not a valid data node"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Validates all required nodes" {
  payload=$(cat <<-END
code.build: {}

web.main: {}

worker.main: {}

data.db: {}
END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
code.build: 
  engine: "Cannot be empty"
data.db: 
  image: "Cannot be empty"
web.main: 
  start: "Cannot be empty"
worker.main: 
  start: "Cannot be empty"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Stop Container" {
  stop_container
}
