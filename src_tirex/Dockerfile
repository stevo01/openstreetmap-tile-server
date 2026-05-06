FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# Install packages from Debian (tirex available in trixie/bookworm)
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates curl wget git procps nano mc psmisc cron sudo \
    python3-psycopg2 python3-yaml gdal-bin \
    file unzip build-essential cmake

# node-carto

RUN apt-get install --no-install-recommends -y \
    libipc-sharelite-perl libjson-perl libgd-gd2-perl libwww-perl \
    libmapscript-perl libhttp-async-perl

RUN apt-get install --no-install-recommends -y \
    python3-mapnik libmapnik-dev mapnik-utils nik4 node-carto 
    

#apt-get install -y python3-mapnik libmapnik-dev mapnik-utils
# && rm -rf /var/lib/apt/lists/*

# create renderer user
RUN useradd -m -s /bin/bash renderer || true

USER renderer
# prepare openstreetmap-carto
WORKDIR /home/renderer/src
# clone styles
RUN git clone https://github.com/gravitystorm/openstreetmap-carto \
    && cd openstreetmap-carto \
    && git fetch --all \
    && git switch --detach v5.9.0

WORKDIR /home/renderer/src/openstreetmap-carto

# copy project.mml file to carto working dir
COPY project.mml /home/renderer/src/openstreetmap-carto

# generate mapnik.xml if carto is present; continue on error
RUN carto project.mml > mapnik.xml || true

WORKDIR /home/renderer/src/openstreetmap-carto
# install fonts
RUN mkdir -p fonts
RUN sed -i "s|https://fonts.google.com/download?family=Noto%20Emoji|https://archive.org/download/noto-emoji/Noto_Emoji.zip|g" /home/renderer/src/openstreetmap-carto/scripts/get-fonts.sh
RUN scripts/get-fonts.sh 


# clone, build and install tirex
# according to fpllowing wiki article:
#   https://wiki.openstreetmap.org/wiki/Tirex/Building_and_Installing
WORKDIR /home/renderer/src/
USER renderer
RUN git clone https://github.com/openstreetmap/tirex.git \
 && git -C tirex checkout v0.8.0
WORKDIR /home/renderer/src/tirex
RUN make

USER root
RUN make install
RUN  mkdir -p /var/lib/tirex \
  && mkdir -p /var/log/tirex \
  && mkdir -p /var/run/tirex \
  && mkdir -p /var/lib/mod_tile/ajt \
  && chown renderer:renderer /var/lib/tirex \
  && chown renderer:renderer /var/run/tirex \
  && chown renderer:renderer /var/log/tirex \
  && chown renderer /var/lib/mod_tile/ajt

COPY ajt.conf    /etc/tirex/renderer/mapnik/
COPY mapnik.conf /etc/tirex/renderer/
COPY tirex.conf  /etc/tirex/tirex.conf


RUN mv /etc/tirex/renderer/openseamap/openseamap.conf /etc/tirex/renderer/openseamap/openseamap.conf.disabled
RUN mv /etc/tirex/renderer/openseamap.conf       /etc/tirex/renderer/openseamap.conf.disabled
#RUN mv /etc/tirex/renderer/openseamap.conf.dist  /etc/tirex/renderer/openseamap.conf.dist.disabled


# ensure renderer owns style files
RUN chown -R renderer:renderer /src/openstreetmap-carto || true

COPY run_tirex.sh /run_tirex.sh
RUN chmod +x /run_tirex.sh

ENTRYPOINT ["/run_tirex.sh"]
CMD ["run"]
