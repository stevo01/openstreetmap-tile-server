FROM ubuntu:18.04

# Based on
# https://switch2osm.org/manually-building-a-tile-server-18-04-lts/

# Set up environment
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install dependencies
RUN apt-get update \
  && apt-get install -y wget gnupg2 lsb-core apt-transport-https ca-certificates curl \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && echo "deb [ trusted=yes ] https://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
  && wget --quiet -O - https://deb.nodesource.com/setup_10.x | bash - \
  && apt-get update \
  && apt-get install -y nodejs

RUN apt-get install -y --no-install-recommends --allow-unauthenticated \
  apache2 \
  apache2-dev \
  autoconf \
  build-essential \
  bzip2 \
  cmake \
  fonts-noto-cjk \
  fonts-noto-hinted \
  fonts-noto-unhinted \
  clang \
  gdal-bin \
  git-core \
  libagg-dev \
  libboost-all-dev \
  libbz2-dev \
  libcairo-dev \
  libcairomm-1.0-dev \
  libexpat1-dev \
  libfreetype6-dev \
  libgdal-dev \
  libgeos++-dev \
  libgeos-dev \
  libgeotiff-epsg \
  libicu-dev \
  liblua5.3-dev \
  libmapnik-dev \
  libpq-dev \
  libproj-dev \
  libprotobuf-c0-dev \
  libtiff5-dev \
  libtool \
  libxml2-dev \
  lua5.3 \
  make \
  mapnik-utils \
  protobuf-c-compiler \
  python-mapnik \
  python-pip \
  python-setuptools \
  sudo \
  tar \
  ttf-unifont \
  unzip \
  wget \
  zlib1g-dev \
  nano mc psmisc \
  libipc-sharelite-perl libjson-perl libgd-gd2-perl libwww-perl devscripts \
&& apt-get clean autoclean \
&& apt-get autoremove --yes \
&& rm -rf /var/lib/{apt,dpkg,cache,log}

RUN pip install pyyaml

# Set up renderer user
RUN adduser --disabled-password --gecos "" renderer
USER renderer

# Install and test Mapnik
RUN python -c 'import mapnik'

# Install mod_tile and renderd
USER root
WORKDIR /home/renderer/src
RUN mkdir -p /home/renderer/src \
    && chown renderer:renderer /home/renderer/src
USER renderer
RUN git clone -b switch2osm https://github.com/SomeoneElseOSM/mod_tile.git
WORKDIR /home/renderer/src/mod_tile
RUN ./autogen.sh \
  && ./configure \
  && make -j $(nproc)
USER root
RUN make -j $(nproc) install \
  && make -j $(nproc) install-mod_tile \
  && ldconfig
USER renderer

# Configure stylesheet
WORKDIR /home/renderer/src
RUN git clone https://github.com/gravitystorm/openstreetmap-carto.git \
 && git -C openstreetmap-carto checkout v4.23.0

# copy project.mml file to carto working dir
COPY project.mml /home/renderer/src/openstreetmap-carto

WORKDIR /home/renderer/src/openstreetmap-carto
USER root
# RUN npm install -g carto@0.18.2
RUN npm install -g carto
USER renderer
RUN carto project.mml > mapnik.xml

# Load shapefiles
WORKDIR /home/renderer/src/openstreetmap-carto
RUN scripts/get-shapefiles.py

# Configure renderd
USER root
RUN sed -i 's/renderaccount/renderer/g' /usr/local/etc/renderd.conf \
  && sed -i 's/hot/tile/g' /usr/local/etc/renderd.conf
USER renderer

# Configure Apache
USER root
RUN  mkdir /var/lib/mod_tile \
  && chown renderer:renderer /var/lib/mod_tile \
  && mkdir /var/run/renderd \
  && chown renderer /var/run/renderd
RUN echo "LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so" >> /etc/apache2/conf-available/mod_tile.conf \
    && echo "LoadModule headers_module /usr/lib/apache2/modules/mod_headers.so" >> /etc/apache2/conf-available/mod_headers.conf \
  && a2enconf mod_tile && a2enconf mod_headers
COPY apache.conf /etc/apache2/sites-available/000-default.conf
COPY leaflet-demo.html /var/www/html/index.html
RUN ln -sf /dev/stdout /var/log/apache2/access.log \
  && ln -sf /dev/stderr /var/log/apache2/error.log

# clone, build and install tirex
# according to fpllowing wiki article:
#   https://wiki.openstreetmap.org/wiki/Tirex/Building_and_Installing
USER renderer
WORKDIR /home/renderer/src
RUN git clone https://github.com/openstreetmap/tirex.git \
 && git -C tirex checkout v0.6.1
WORKDIR /home/renderer/src/tirex
RUN make

USER root
RUN make install
RUN  mkdir /var/lib/tirex \
  && mkdir /var/log/tirex \
  && mkdir /var/run/tirex \
  && mkdir /var/lib/mod_tile/ajt \
  && chown renderer:renderer /var/lib/tirex \
  && chown renderer:renderer /var/run/tirex \
  && chown renderer:renderer /var/log/tirex \
  && chown renderer /var/lib/mod_tile/ajt

COPY ajt.conf /etc/tirex/renderer/mapnik/
COPY mapnik.conf /etc/tirex/renderer/
COPY tirex.conf /etc/tirex/tirex.conf

RUN ln -s /var/lib/mod_tile  /var/lib/tirex/tiles

# remove not required tirex sample renderer and maps
RUN  rm -fr /etc/tirex/renderer/openseamap \
	&& rm -fr /etc/tirex/renderer/wms \
	&& rm -fr /etc/tirex/renderer/mapserver \
	&& rm -fr /etc/tirex/renderer/openseamap.conf \
	&& rm -fr /etc/tirex/renderer/wms.conf \
	&& rm -fr /etc/tirex/renderer/mapserver.conf

# Start running
USER root
COPY run.sh /
ENTRYPOINT ["/run.sh"]
CMD []

EXPOSE 80
