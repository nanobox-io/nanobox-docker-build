# unless this is in the build bin script?
execute 'cp -r /mnt/deploy/code/. /data/code/'

if boxfile[:plugin]
  # verify engine is specified
  exit HOOKIT::ABORT unless boxfile[:engine]
end

# get language
engine = boxfile[:engine].split('/')[-1]

# set engine in registry
registry ('engine', engine)
registry ('engine', boxfile[:plugin]) if boxfile[:plugin]

# things in /mnt are from boot2docker host
# things in /share are from host system

# not mounted to host os
# /mnt/engines/
# /mnt/plugins/

execute "cp -r /share/engines/#{engine} /opt/engines/#{engine}/plugins" unless ! File.exist?('/share/engines/#{engine}')

if boxfile[:plugin]
  execute "cp -r /share/plugins/#{boxfile[:plugin]} /opt/engines/#{engine}/plugins" unless ! File.exist?('/share/plugins/#{boxfile[:plugin]}')
end
