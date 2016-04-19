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
puts engine_url_type(ARGV.first)

END
)"

  run docker exec build bash -c "echo \"${script}\" > /tmp/url_type"
  run docker exec build bash -c "chmod +x /tmp/url_type"
  run docker exec build bash -c " [ -f /tmp/url_type ] "

  [ "$status" -eq 0 ]
}

@test "Git ssh url" {
  url=git@github.com:nanobox-io/nanobox-hooks-hoarder.git
  run docker exec build bash -c "/tmp/url_type $url"
  [ "$output" = "git" ]
}

@test "Git http url" {
  url=https://github.com/nanobox-io/nanobox-hooks-hoarder.git
  run docker exec build bash -c "/tmp/url_type $url"
  [ "$output" = "git" ]
}

@test "Github url" {
  url=nanobox-io/nanobox-hooks-hoarder
  run docker exec build bash -c "/tmp/url_type $url"
  [ "$output" = "github" ]
}

@test "Tarball .tar.gz url" {
  url=https://github.com/nanopack/hookit/archive/v0.12.1.tar.gz
  run docker exec build bash -c "/tmp/url_type $url"
  [ "$output" = "tarball" ]
}

@test "Tarball .tgz url" {
  url=https://github.com/nanopack/hookit/archive/v0.12.1.tgz
  run docker exec build bash -c "/tmp/url_type $url"
  [ "$output" = "tarball" ]
}

@test "Absolute filepath url" {
  url=/Users/tylerflint/apps/cool-one
  run docker exec build bash -c "/tmp/url_type $url"
  [ "$output" = "filepath" ]
}

@test "Relative filepath url" {
  url=./apps/cool-one
  run docker exec build bash -c "/tmp/url_type $url"
  [ "$output" = "filepath" ]
}

@test "Stop Container" {
  stop_container
}
