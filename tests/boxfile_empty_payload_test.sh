echo running tests for build
UUID=$(cat /proc/sys/kernel/random/uuid)

pass "unable to start the $VERSION container" docker run --privileged=true -d --name $UUID nanobox/build sleep 365d

defer docker kill $UUID

pass "create hookit db folder" docker exec $UUID mkdir -p /var/db/hookit

pass "unable to set engine" docker exec $UUID bash -c 'echo '"'"'{"engine":"3-php"}'"'"' > /var/db/hookit/db.json'

pass "unable to run boxfile with empty payload" docker exec $UUID /opt/bin/default-boxfile '{}'
