util_dir="$(dirname $(readlink -f $BASH_SOURCE))"
hookit_dir="$(readlink -f ${util_dir}/../../files/opt/nanobox/hooks)"
payloads_dir=$(readlink -f ${util_dir}/../payloads)
apps_dir=$(readlink -f ${util_dir}/../apps)

print_output() {
  for (( i=0; i < ${#lines[*]}; i++ ))
  do
    echo ${lines[$i]}
  done
}

payload() {
  cat ${payloads_dir}/${1}.json
}

run_hook() {
  hook=$1
  payload=$2

  docker exec \
    build \
    /opt/nanobox/hooks/$hook "$payload"
}

start_container() {
  app=$1

  if [[ -z $app ]]; then
    app="simple-nodejs"
  fi

  docker run \
    --name=build \
    -d \
    -e "PATH=$(path)" \
    --privileged \
    --net=nanobox \
    --ip=192.168.0.2 \
    --volume=${hookit_dir}/:/opt/nanobox/hooks \
    --volume=${apps_dir}/${app}/:/share/code \
    nanobox/build
}

stop_container() {
  docker stop build
  docker rm build
}

path() {
  paths=(
    "/opt/gonano/sbin"
    "/opt/gonano/bin"
    "/opt/gonano/bin"
    "/usr/local/sbin"
    "/usr/local/bin"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
  )

  path=""

  for dir in ${paths[@]}; do
    if [[ "$path" != "" ]]; then
      path="${path}:"
    fi

    path="${path}${dir}"
  done

  echo $path
}

run_build() {
  /opt/nanobox/hooks/user "$(cat payloads/user.json)"
  /opt/nanobox/hooks/configure "$(cat payloads/configure.json)"
  /opt/nanobox/hooks/fetch "$(cat payloads/fetch.json)"
  /opt/nanobox/hooks/setup "$(cat payloads/setup.json)"
  /opt/nanobox/hooks/boxfile "$(cat payloads/boxfile.json)" > /dev/null
  /opt/nanobox/hooks/build "$(cat payloads/build.json)"
  /opt/nanobox/hooks/compile "$(cat payloads/compile.json)"
  /opt/nanobox/hooks/pack-app "$(cat payloads/pack-app.json)"
  /opt/nanobox/hooks/pack-build "$(cat payloads/pack-build.json)"
  /opt/nanobox/hooks/clean "$(cat payloads/clean.json)"
  /opt/nanobox/hooks/pack-deploy "$(cat payloads/pack-deploy.json)"
}
