# source docker helpers
. util/helpers.sh

@test "Start Container" {
  start_container
}

@test "Create commitish test script" {
  script="$(cat <<-END
#!/usr/bin/env ruby

require '/opt/nanobox/hooks/lib/engine.rb'

include Nanobox::Engine

# Just echo the url type
puts engine_git_commitish(ARGV.first)

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/git_commitish"
  run docker exec build bash -c "chmod +x /tmp/git_commitish"
  run docker exec build bash -c " [ -f /tmp/git_commitish ] "

  [ "$status" -eq 0 ]
}

@test "Returns commitish when provided" {
  url=git@github.com:nanobox-io/nanobox-hooks-hoarder.git#feature/simplified
  run docker exec build bash -c "/tmp/git_commitish $url"
  [ "$output" = "feature/simplified" ]
}

@test "Returns master when not provided" {
  url=git@github.com:nanobox-io/nanobox-hooks-hoarder.git
  run docker exec build bash -c "/tmp/git_commitish $url"
  [ "$output" = "" ]
}

@test "Stop Container" {
  stop_container
}
