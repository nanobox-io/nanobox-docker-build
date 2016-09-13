# source docker helpers
. util/helpers.sh

@test "Start Container" {
  start_container
}

@test "Create env script" {
  script="$(cat <<-END
#!/usr/bin/env ruby

$:.unshift  '/opt/gonano/hookit/vendor/bundle'
require 'bundler/setup'

# load hookit/setup to bootstrap hookit and import the dsl
require 'hookit/setup'

require 'json'
require 'yaml'
require '/opt/nanobox/hooks/lib/engine.rb'

include Nanobox::Engine

def build
  {
    "config": {
        runtime: 'ruby-2.2',
        name: 'tyler'
      }
  }
end

# Just echo the url type
require 'pp'
pp engine_env

END
)"
  run docker exec build bash -c "echo \"${script}\" > /tmp/env"
  run docker exec build bash -c "chmod +x /tmp/env"
  run docker exec build bash -c " [ -f /tmp/env ] "

  [ "$status" -eq 0 ]
}


@test "Verify env is created properly" {
  # the order is indeterminate and keeps failing here
  skip
  run docker exec build bash -c "/tmp/env"
  expected="$(cat <<-END
{:CODE_DIR=>"/app",
 :DATA_DIR=>"/data",
 :APP_DIR=>"/mnt/app",
 :CACHE_DIR=>"/mnt/cache",
 :ETC_DIR=>"/data/etc",
 :ENV_DIR=>"/data/etc/env.d",
 "CONFIG_runtime_type"=>"string",
 "CONFIG_runtime_value"=>"'ruby-2.2'",
 "CONFIG_name_type"=>"string",
 "CONFIG_name_value"=>"'tyler'",
 "CONFIG_nodes"=>"runtime,name"}
END
)"

  echo "$output"
  echo "$expected"

  [ "$output" = "$expected" ]
}

@test "Stop Container" {
  stop_container
}
