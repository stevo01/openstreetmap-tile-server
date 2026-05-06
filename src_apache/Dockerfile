FROM debian:13

# Web image: Apache + mod_tile
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates apache2 libapache2-mod-tile iputils-ping \
  && rm -rf /var/lib/apt/lists/*

COPY run_apache.sh /run_apache.sh
RUN chmod +x /run_apache.sh

EXPOSE 80
ENTRYPOINT ["/run_apache.sh"]
CMD ["run"]
