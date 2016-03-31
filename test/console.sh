#!/bin/bash
#
# Launch a container and console into it

test_dir="$(dirname $(readlink -f $BASH_SOURCE))"
payload_dir="$(readlink -f ${test_dir}/payloads)"
hookit_dir="$(readlink -f ${test_dir}/../files/opt/nanobox/hooks)"

docker run \
  --name=test-console \
  -d \
  --privileged \
  --net=nanobox \
  --ip=192.168.0.55 \
  --volume=${hookit_dir}/:/opt/nanobox/hooks \
  --volume=${payload_dir}/:/payloads \
  nanobox/build

docker exec -it test-console bash

docker stop test-console
docker rm test-console
