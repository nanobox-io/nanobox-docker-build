# source docker helpers
. util/helpers.sh
. util/warehouse.sh

@test "Start Container" {
  start_container
}

@test "Run user Hook" {
  run run_hook "user" "$(payload user)"
  print_output
  [ "$status" -eq 0 ]

  # ensure the keys were installed
  run docker exec build bash -c "[ -f /home/gonano/.ssh/id_rsa ] "
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -f /home/gonano/.ssh/id_rsa.pub ] "
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "user" "$(payload user)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run configure hook" {
  run run_hook "configure" "$(payload configure)"
  print_output
  [ "$status" -eq 0 ]

  # verify required directories exist
  run docker exec build bash -c "[ -d /data ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /data/etc ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /data/etc/env.d ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/build ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/deploy ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/app ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/cache ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /app ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/cache/app ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/cache/lib_dirs ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /opt/nanobox/engine ]"
  [ "$status" -eq 0 ]

  # todo: what about pkgin?

  # second run, don't break
  run run_hook "configure" "$(payload configure)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run fetch hook" {
  
  # link /mnt/app to /app
  run docker exec build bash -c "cp -a /share/code/* /app"
  
  run run_hook "fetch" "$(payload fetch)"
  print_output
  [ "$status" -eq 0 ]

  # verify the nodejs engine is installed
  run docker exec build bash -c "[ -f /opt/nanobox/engine/lib/nodejs.sh ]"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "fetch" "$(payload fetch)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run setup hook" {
  run run_hook "setup" "$(payload setup)"
  print_output
  [ "$status" -eq 0 ]

  # verify? - this engine doesn't have a setup so, it has no verification

  # second run, don't break
  run run_hook "setup" "$(payload setup)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run boxfile hook" {
  run run_hook "boxfile" "$(payload boxfile)"
  print_output
  [ "$status" -eq 0 ]

  # verify the output
  # [ "${lines[0]}" = "--- " ]
  # [ "${lines[1]}" = "code.build: " ]
  # [ "${lines[2]}" = "  engine: nodejs#refactor/v1 " ]
  # [ "${lines[3]}" = "  lib_dirs: " ]
  # [ "${lines[4]}" = "    - node_modules " ]

  # second run, don't break
  run run_hook "boxfile" "$(payload boxfile)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run build hook" {
  run run_hook "build" "$(payload build)"
  print_output
  [ "$status" -eq 0 ]

  # verify build hook ran?
  run docker exec build bash -c "[ -f /data/bin/node ]"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "build" "$(payload build)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run compile hook" {
  
  # remove /app/* from build
  run docker exec build bash -c "rm -rf /app/*"
  
  run run_hook "compile" "$(payload compile)"
  print_output
  [ "$status" -eq 0 ]

  # verify the code was copied over
  run docker exec build bash -c "[ -f /app/package.json ]"
  print_output
  [ "$status" -eq 0 ]

  # verify the .nanoignore was ignored
  run docker exec build bash -c "[ ! -f /app/.nanoignore ]"
  print_output
  [ "$status" -eq 0 ]

  # verify the contents of .nanoignore was ignored
  run docker exec build bash -c "[ ! -f /app/badfile ]"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "compile" "$(payload compile)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run pack-app hook" {
  run run_hook "pack-app" "$(payload pack-app)"
  print_output
  [ "$status" -eq 0 ]

  # Verify
  run docker exec build bash -c "[ -f /mnt/app/server.js ]"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "pack-app" "$(payload pack-app)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run pack-build hook" {
  run run_hook "pack-build" "$(payload pack-build)"
  print_output
  [ "$status" -eq 0 ]

  # Verify
  run docker exec build bash -c "[ -f /mnt/build/bin/node ]"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "pack-build" "$(payload pack-build)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run clean hook" {
  run run_hook "clean" "$(payload clean)"
  print_output
  [ "$status" -eq 0 ]

  # Verify
  run docker exec build bash -c "[ ! -f /data/bin/python ]"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "clean" "$(payload clean)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run pack-deploy hook" {
  run run_hook "pack-deploy" "$(payload pack-deploy)"
  print_output
  [ "$status" -eq 0 ]

  # Verify
  run docker exec build bash -c "[ -f /mnt/deploy/bin/node ]"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "pack-deploy" "$(payload pack-deploy)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Start warehouse" {
  start_warehouse
}

@test "Run publish hook" {
  run run_hook "publish" "$(payload publish)"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "publish" "$(payload publish)"
  print_output
  [ "$status" -eq 0 ]
}

@test "Run publish hook with previous build" {
  run run_hook "publish" "$(payload publish-slurp)"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "publish" "$(payload publish-slurp)"
  print_output
  [ "$status" -eq 0 ]
}

# @test "Extract a build and ensure all files are present" {
#   
#   mkdir -p /tmp/app
#   
#   curl \
#     -k \
#     -H "x-auth-token: 123" \
#     https://192.168.0.100:7410/blobs/app-123abc.tgz \
#       | tar \
#         -xzf \
#         - \
#         -C /tmp/app
#         
#   [ -f /tmp/app/.hidden/test.txt ]
# }

@test "Stop Container" {
  stop_container
  stop_warehouse
}
