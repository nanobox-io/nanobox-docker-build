#!/bin/bash
#
# Launch a container and console into it, providing a complete sandbox environment

test_dir="$(dirname $(readlink -f $BASH_SOURCE))"
payload_dir="$(readlink -f ${test_dir}/payloads)"
util_dir="$(readlink -f ${test_dir}/util)"
hookit_dir="$(readlink -f ${test_dir}/../files/opt/nanobox/hooks)"

# source the warehouse helpers
. ${util_dir}/warehouse.sh

# spawn a warehouse
echo "Launching a warehouse container..."
start_warehouse

# start a container for a sandbox
echo "Launching a sandbox container..."
docker run \
  --name=test-console \
  -d \
  --privileged \
  --net=nanobox \
  --ip=192.168.0.55 \
  --volume=${hookit_dir}/:/opt/nanobox/hooks \
  --volume=${payload_dir}/:/payloads \
  nanobox/build

# hop into the sandbox
echo "Consoling into the sandbox..."
docker exec -it test-console bash

# remove the sandbox
echo "Destroying the sandbox container..."
docker stop test-console
docker rm test-console

# remove the warehouse
echo "Destroying the warehouse container..."
stop_warehouse

echo "Bye."
