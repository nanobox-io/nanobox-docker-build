FROM nanobox/base

# generate required directories
RUN mkdir -p /data
RUN mkdir -p /var/nanobox
RUN mkdir -p /data/var/db

# install build and other tools required for engine
RUN curl -s http://pkgsrc.nanobox.io/nanobox/base/Linux/bootstrap.tar.gz | tar -C / -zxf - && \
    echo "http://pkgsrc.nanobox.io/nanobox/base/Linux/" > /data/etc/pkgin/repositories.conf && \
    /data/sbin/pkg_admin rebuild && \
    rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up && \
    /data/bin/pkgin -y in gcc49 build-essential && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/gonano/db/pkgin/cache /data/var/db/pkgin/cache && \
    chown -R gonano /data

RUN /opt/gonano/bin/pkgin -y in shon rsync && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/gonano/db/pkgin/cache /data/var/db/pkgin/cache

# link make to gmake
RUN ln -s /data/bin/gmake /data/bin/make

# Allow ssh
EXPOSE 22

# Run runit automatically
CMD /sbin/my_init
