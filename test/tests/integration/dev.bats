# source docker helpers
. util/helpers.sh
. util/warehouse.sh

@test "Start Container" {
  start_container
}

@test "Run dev Hook" {
  run run_hook "dev" "$(payload dev)"
  print_output
  [ "$status" -eq 0 ]

  # second run, don't break
  run run_hook "dev" "$(payload dev)"
  print_output
  [ "$status" -eq 0 ]

  run docker exec build iptables -t nat -S PREROUTING
  echo "$output"
  [ "$status" -eq 0 ]
  expected=$(cat <<-END
-P PREROUTING ACCEPT
-A PREROUTING -i eth0 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
END
)
  [ "$output" = "$expected" ]
}

@test "Stop Container" {
  stop_container
}