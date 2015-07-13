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

# Install engines
# RUN nanobox fetch | tar -C /opt/engines/ -zxf -

# Allow ssh
EXPOSE 22

# Run runit automatically
CMD /sbin/my_init
