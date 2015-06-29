FROM nanobox/base

# 'mount' data dir
RUN mkdir -p /data

# Install pkgin packages
ADD http://pkgsrc.nanobox.io/nanobox/base/Linux/bootstrap.tar.gz /data/
RUN tar -C / -zxf /data/bootstrap.tar.gz
RUN rm -f /data/bootstrap.tar.gz
RUN echo "http://pkgsrc.nanobox.io/nanobox/base/Linux/" > /data/etc/pkgin/repositories.conf
RUN mkdir -p /data/var/db
RUN /data/sbin/pkg_admin rebuild
RUN rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up
RUN /data/bin/pkgin -y in build-essential
#TEMP
RUN ln -s /data/bin/gmake /data/bin/make

# install tools required for engine
RUN /opt/gonano/bin/pkgin -y in shon

# Cleanup disk
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/gonano/db/pkgin /data/var/db/pkgin

# Allow ssh
EXPOSE 22

# Run runit automatically
CMD /sbin/my_init
