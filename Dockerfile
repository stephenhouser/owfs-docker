# owfs owserver
FROM ubuntu:latest
LABEL maintainer "Stephen Houser - https://github.com/stephenhouser"

VOLUME /data 
VOLUME /config

RUN apt-get update && \
    apt-get install -y owserver ow-shell && \
    rm -rf /var/lib/apt/lists/*

# Note: To be really useful, you'll need to mount/copy your own owfs.conf
#       but we'll make the stock "fake" one actually work...
RUN sed -i -e "s/localhost:4304/\*:4304/g" /etc/owfs.conf

EXPOSE 4304
CMD /usr/bin/owserver -c /etc/owfs.conf --foreground
