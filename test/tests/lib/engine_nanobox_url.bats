# source docker helpers
. util/helpers.sh

@test "Start Container" {
  start_container
}

@test "Create url test script" {
  script="$(cat <<-END
#!/usr/bin/env ruby

require '/opt/nanobox/hooks/lib/engine.rb'

include Nanobox::Engine

# Just echo the url type
puts engine_nanobox_url(ARGV.first)

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/nanobox_url"
  run docker exec build bash -c "chmod +x /tmp/nanobox_url"
  run docker exec build bash -c " [ -f /tmp/nanobox_url ] "

  [ "$status" -eq 0 ]
}

@test "Returns a full url" {
  engine=ruby
  run docker exec build bash -c "/tmp/nanobox_url $engine"
  [ "$output" = "https://github.com/nanobox-io/nanobox-engine-ruby.git" ]
}

@test "Stop Container" {
  stop_container
}
