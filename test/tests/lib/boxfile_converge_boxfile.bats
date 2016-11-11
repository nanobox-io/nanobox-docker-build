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
  payload='{"run.config":{},"web.site":{"start":"something"},"worker.jobs":{"start":"something"},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  
  expected=$(cat <<-END
---
web.site:
  start: something
worker.jobs:
  start: something
data.db:
  image: nanobox/mysql
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Test hash start commands" {
  payload='{"run.config":{},"web.site":{"start":{"worker":"something"}},"worker.jobs":{"start":{"worker":"something"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  
  expected=$(cat <<-END
---
web.site:
  start:
    worker: something
worker.jobs:
  start:
    worker: something
data.db:
  image: nanobox/mysql
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Test string and hash start commands" {
  payload='{"run.config":{},"web.site":{"start":"something"},"worker.jobs":{"start":{"worker":"something"}},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  
  expected=$(cat <<-END
---
web.site:
  start: something
worker.jobs:
  start:
    worker: something
data.db:
  image: nanobox/mysql
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
}

@test "Converge using complex names for services" {
  payload='{"deploy.config":{"before_live":{"web.site":["echo hi"]}},"web.site":{},"data.db":{"image":"nanobox/mysql"}}'
  run docker exec build bash -c "/tmp/converge_boxfile '$payload'"
  
  expected=$(cat <<-END
---
deploy.config:
  before_live:
    web.site:
    - echo hi
data.db:
  image: nanobox/mysql
END
)

  echo "$output"
  
  [ "$output" = "$expected" ]
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
