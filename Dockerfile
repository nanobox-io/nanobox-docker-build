FROM nanobox/runit

# install gcc and build tools
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential git rsync openssh-client && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# install other tools required for engine
RUN rm -rf /var/gonano/db/pkgin && /opt/gonano/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in shon mustache siphon && \
    rm -rf /var/gonano/db/pkgin/cache

# add temporary scripts
ADD scripts/. /var/tmp/

# generate build exclude list
ADD files/build-exceptions.txt /var/nanobox/build-exceptions.txt
RUN /var/tmp/generate-build-excludes

# update pkgin remote packages
RUN rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up && \
    rm -rf /data/var/db/pkgin/cache && \
    chown -R gonano /data/var/db/pkgin

# Created necessary directories
RUN mkdir -p /opt/nanobox

# Copy files
ADD files/opt/nanobox/. /opt/nanobox/

# install nos
RUN mkdir -p /opt/pagodabox/nos && \
    curl \
      -k \
      -s \
      -L \
      https://github.com/pagodabox/nanobox-nos/archive/v0.10.1.tar.gz \
        | tar \
            -xzf - \
            --strip-components=1 \
            -C /opt/pagodabox/nos/

# Install engines
RUN /var/tmp/install-engines

# Cleanup disk
RUN rm -rf /tmp/* /var/tmp/*


CMD [ "/opt/gonano/bin/nanoinit", "/bin/sleep 365d" ]
