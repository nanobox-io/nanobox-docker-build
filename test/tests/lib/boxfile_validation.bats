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
run.config:
  engine: ruby
END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"

  echo "$output"

  [ "$output" = "--- {}" ]
}

@test "Should require an engine" {
  payload=$(cat <<-END
run.config:
  engine.config: {}
END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"

  expected=$(cat <<-END
--- 
run.config: 
  engine: "Cannot be empty"
END
)

  echo "$output"

  [ "$output" = "$expected" ]
}

@test "Should enforce proper types" {
  payload=$(cat <<-END
run.config:
  engine: 1
web.main:
  start: true
  log_watch: ok
END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"

  expected=$(cat <<-END
--- 
run.config: 
  engine: "Must be a string"
web.main: 
  log_watch: "Must be a hash"
  start: "Must be a string, an array of strings or a hash"
END
)

  echo "$output"

  [ "$output" = "$expected" ]
}

@test "Ensures writable dirs reference actual components" {
  payload=$(cat <<-END
run.config:
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
run.config: {}

web.main: {}

worker.main: {}

data.db: {}
END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
data.db: 
  image: "Cannot be empty"
run.config: 
  engine: "Cannot be empty"
web.main: 
  start: "Cannot be empty"
worker.main: 
  start: "Cannot be empty"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Validate ports" {
  payload=$(cat <<-END
run.config:
    engine: ruby
    
web.main:
  start: bash
  ports:
    - 123456

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  ports: "Invalid port format - 123456"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
    engine: ruby
    
web.main:
  start: bash
  ports:
    - 12345:123456

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  ports: "Invalid port format - 12345:123456"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
    engine: ruby
    
web.main:
  start: bash
  ports:
    - tcp:1234:123456

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  ports: "Invalid port format - tcp:1234:123456"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
    engine: ruby
    
web.main:
  start: bash
  ports:
    - garbage

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  ports: "Invalid port format - garbage"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
    engine: ruby
    
web.main:
  start: bash
  ports:
    - "1234"
    - 2345:6789
    - tcp:123:456
    - udp:678:901

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Validate start and stop commands as bad hashes" {
  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop:
    app: that
    blob: blah

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop_blob: "stop blob needs a matching key in start"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]


  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop_force:
    app: true
    blob: true

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop_force_blob: "stop_force blob needs a matching key in start"
END
)
  
  echo "$output"

  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  cwd:
    app: that
    blob: blah

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  cwd_blob: "cwd blob needs a matching key in start"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop_timeout:
    app: 10
    blob: 20

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop_timeout_blob: "stop_timeout blob needs a matching key in start"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Validate start and stop commands mismatch string and hash" {
  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start: this
  stop:
    app: that
    blob: blah

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop: "stop needs to be a string"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]


  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start: this
  stop_force:
    app: true
    blob: true

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop_force: "stop_force needs to be true or false"
END
)
  
  echo "$output"

  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start: this
  cwd:
    app: that
    blob: blah

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  cwd: "cwd needs to be a string"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start: this
  stop_timeout:
    app: 10
    blob: 20

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop_timeout: "stop_timeout needs to be an integer"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Validate start and stop commands mismatch hash and string" {
  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop: that

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop: "stop needs to be a hash"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]


  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop_force: true

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop_force: "stop_force needs to be a hash"
END
)
  
  echo "$output"

  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  cwd: blah

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  cwd: "cwd needs to be a hash"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop_timeout: 20

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- 
web.main: 
  stop_timeout: "stop_timeout needs to be an hash"
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Validate start and stop commands as good hashes" {
  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop:
    app: that

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]


  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop_force:
    app: true

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)
  
  echo "$output"

  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  cwd:
    app: that

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start:
    app: this
  stop_timeout:
    app: 10

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Validate start and stop commands as good strings" {
  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start: this
  stop: that

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]


  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start: this
  stop_force: true

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)
  
  echo "$output"

  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start: this
  cwd: that

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]

  payload=$(cat <<-END
run.config:
  engine: ruby
    
web.main:
  start: this
  stop_timeout: 10

END
)

  run docker exec build bash -c "/tmp/validate_boxfile '{}' '$payload'"
  
  expected=$(cat <<-END
--- {}
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Stop Container" {
  stop_container
}
