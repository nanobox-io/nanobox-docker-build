FROM nanobox/base

# generate required directories
RUN mkdir -p /data
RUN mkdir -p /var/nanobox
RUN mkdir -p /data/var/db

# install libc6 for build headers
RUN apt-get update -qq && \
    apt-get install -y libc6-dev && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# install build and other tools required for engine
RUN curl -s http://pkgsrc.nanobox.io/nanobox/base/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://pkgsrc.nanobox.io/nanobox/base/Linux/" > /data/etc/pkgin/repositories.conf && \
    /data/sbin/pkg_admin rebuild && \
    rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up && \
    /data/bin/pkgin -y in gcc49 build-essential && \
    rm -rf /data/var/db/pkgin/cache && \
    chown -R gonano /data

RUN rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in shon rsync && \
    rm -rf /var/gonano/db/pkgin/cache

# link make to gmake
RUN ln -s /data/bin/gmake /data/bin/make
