echo running tests for build
UUID=$(cat /proc/sys/kernel/random/uuid)

pass "unable to start the $VERSION container" docker run --privileged=true -d --name $UUID nanobox/build

defer docker kill $UUID

pass "unable to set engine" docker exec -it $UUID bash -c 'echo '"'"'{"engine":"3-php"}'"'"' > /var/db/hookit/db.json'

pass "unable to run boxfile with empty payload" docker exec -it $UUID /opt/bin/default-boxfile '{}'
