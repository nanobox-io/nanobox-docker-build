echo running tests for build
UUID=$(cat /proc/sys/kernel/random/uuid)

pass "unable to start the $VERSION container" docker run --privileged=true -d --name $UUID nanobox/build

pass "unable to run boxfile with empty payload" docker exec -it $UUID /opt/bin/default-boxfile '{}'

defer docker kill $UUID