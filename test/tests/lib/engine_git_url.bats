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
puts engine_git_url(ARGV.first)

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/git_url"
  run docker exec build bash -c "chmod +x /tmp/git_url"
  run docker exec build bash -c " [ -f /tmp/git_url ] "

  [ "$status" -eq 0 ]
}

@test "Returns repo when commitish provided" {
  url=git@github.com:nanobox-io/nanobox-hooks-hoarder.git#feature/simplified
  run docker exec build bash -c "/tmp/git_url $url"
  [ "$output" = "git@github.com:nanobox-io/nanobox-hooks-hoarder.git" ]
}

@test "Returns repo when commitish not provided" {
  url=git@github.com:nanobox-io/nanobox-hooks-hoarder.git
  run docker exec build bash -c "/tmp/git_url $url"
  [ "$output" = "git@github.com:nanobox-io/nanobox-hooks-hoarder.git" ]
}

@test "Stop Container" {
  stop_container
}
