FROM nanobox/pre-build

# add temporary scripts
ADD scripts/. /var/tmp/

# generate build exclude list
ADD files/build-exceptions.txt /var/nanobox/build-exceptions.txt
RUN /var/tmp/generate-build-excludes

# update pkgin
RUN rm -rf /data/var/db/pkgin && /data/bin/pkgin -y up && \
    rm -rf /var/tmp/* /data/var/db/pkgin/cache
RUN chown -R gonano /data/var/db/pkgin

# Copy files
ADD hookit/. /opt/gonano/hookit/mod/

# install nos
RUN mkdir -p /opt/nos
RUN curl \
  -k \
  -s \
  https://github.com/pagodabox/nanobox-nos/archive/v0.1.0.tar.gz \
    | tar \
        -xzf - \
        -C /opt/nos/

# Install engines
# RUN nanobox fetch | tar -C /opt/engines/ -zxf -

# Allow ssh
EXPOSE 22

# Run runit automatically
CMD /sbin/my_init
