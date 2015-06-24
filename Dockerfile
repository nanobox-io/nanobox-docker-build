FROM nanobox/pre-build

# Copy files
ADD hookit/. /opt/gonano/hookit/mod/

# Install engines
# RUN nanobox fetch | tar -C /opt/engines/ -zxf -

# Allow ssh
EXPOSE 22

# Run runit automatically
CMD /sbin/my_init
