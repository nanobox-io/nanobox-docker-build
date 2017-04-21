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
  run docker exec build bash -c "[ -f /data/var/home/gonano/.ssh/id_rsa ] "
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -f /data/var/home/gonano/.ssh/id_rsa.pub ] "
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
  run docker exec build bash -c "[ -d /mnt/cache/app ]"
  [ "$status" -eq 0 ]
  run docker exec build bash -c "[ -d /mnt/cache/cache_dirs ]"
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
  
  # manually copy the source to simulate a direct mount
  run docker exec build bash -c "mkdir -p /app && chown gonano:gonano /app && cp -a /share/code/* /app/"
  print_output

  run docker exec build bash -c "echo '192.168.0.1	github.com' >> /etc/hosts"
  print_output
  [ "$status" -eq 0 ]

  netcat -l 443 -q 45 &
  
  run run_hook "fetch" "$(payload fetch)"
  print_output
  [ "$status" -eq 1 ]
  [[ "$output" =~ "failed to return within 30 seconds" ]]
}

@test "Stop Container" {
  stop_container
}
