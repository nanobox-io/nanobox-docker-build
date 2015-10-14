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

# add temporary scripts
ADD scripts/. /var/tmp/

# generate build exclude list
ADD files/build-exceptions.txt /var/nanobox/build-exceptions.txt
RUN /var/tmp/generate-build-excludes

# update pkgin remote packages
RUN rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up && \
    rm -rf /data/var/db/pkgin/cache
RUN chown -R gonano /data/var/db/pkgin

# Created necessary directories
RUN mkdir -p /opt/bin

# Copy files
ADD hookit/. /opt/gonano/hookit/mod/
ADD files/opt/bin/. /opt/bin/

# install nos
RUN mkdir -p /opt/nos && \
    curl \
      -k \
      -s \
      -L \
      https://github.com/pagodabox/nanobox-nos/archive/v0.7.3.tar.gz \
        | tar \
            -xzf - \
            --strip-components=1 \
            -C /opt/nos/

# Install engines
RUN /var/tmp/install-engines

# Cleanup disk
RUN rm -rf /tmp/* /var/tmp/*
