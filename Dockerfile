FROM nanobox/base

# Copy files
ADD hookit/. /opt/gonano/hookit/mod/

# 'mount' data dir
RUN mkdir -p /data

# Install pkgin packages
RUN curl -k http://pkgsrc.nanobox.io/nanobox/base/Linux/bootstrap.tar.gz | gunzip -c | tar -C / -xf -
RUN echo "http://pkgsrc.nanobox.io/nanobox/base/Linux/" > /data/etc/pkgin/repositories.conf
RUN mkdir -p /data/var/db
RUN /data/sbin/pkg_admin rebuild
RUN rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up
RUN /data/bin/pkgin -y in build-essential
#TEMP
RUN ln -s /data/bin/gmake /data/bin/make

# Install engines
# RUN nanobox fetch | tar -C /opt/engines/ -zxf -

# Cleanup disk
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /data/var/db/pkgin

# Allow ssh
EXPOSE 22

# Run runit automatically
CMD /sbin/my_init
