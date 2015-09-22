FROM nanobox/base

# generate required directories
RUN mkdir -p /data
RUN mkdir -p /var/nanobox
RUN mkdir -p /data/var/db

# install gcc and build tools
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends build-essential git rsync && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/*

# install other tools required for engine
RUN rm -rf /var/gonano/db/pkgin && /opt/gonano/bin/pkgin -y up && \
    /opt/gonano/bin/pkgin -y in nanobox-cli shon mustache && \
    rm -rf /var/gonano/db/pkgin/cache

# install pkgsrc "base" bootstrap
RUN curl -s http://pkgsrc.nanobox.io/nanobox/base/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://pkgsrc.nanobox.io/nanobox/base/Linux/" > /data/etc/pkgin/repositories.conf && \
    /data/sbin/pkg_admin rebuild && \
    rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up && \
    rm -rf \
      /data/var/db/pkgin \
      /data/share/doc \
      /data/share/ri \
      /data/share/examples \
      /data/opt/gonano/man \
      /data/var/db/pkgin/cache && \
    chown -R gonano /data
