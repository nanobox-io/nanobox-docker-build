FROM nanobox/pre-build

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
RUN mkdir -p /opt/nos
RUN curl \
  -k \
  -s \
  -L \
  https://github.com/pagodabox/nanobox-nos/archive/v0.7.2.tar.gz \
    | tar \
        -xzf - \
        --strip-components=1 \
        -C /opt/nos/

# Install engines
RUN /var/tmp/install-engines

# Cleanup disk
RUN rm -rf /tmp/* /var/tmp/*
