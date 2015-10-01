FROM nanobox/base

# install gcc and build tools
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential git rsync openssh-client && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# install other tools required for engine
RUN rm -rf /var/gonano/db/pkgin && /opt/gonano/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in nanobox-cli shon mustache && \
    rm -rf /var/gonano/db/pkgin/cache
