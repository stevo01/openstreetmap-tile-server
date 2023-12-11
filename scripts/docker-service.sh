#!/bin/bash

# start and stops the osm tile server

set -x

IMAGE_NAME="osmtileserver"

function start() {
  docker run \
      --name $IMAGE_NAME \
      --rm=false \
      --detach \
      --hostname osmtileserver \
      --link osm-tileserver-db:osm-tileserver-db \
      --shm-size=6G \
      -v $PWD/volumes/transfer:/transfer \
      -v openstreetmap-tilecache:/var/lib/mod_tile \
      --label "traefik.enable=true" \
      --label "traefik.http.routers.osmtileserver.entrypoints=http" \
      --label "traefik.http.routers.osmtileserver.rule=Host(\`t2.openseamap.org\`)" \
      --label "traefik.http.middlewares.osmtileserver-https-redirect.redirectscheme.scheme=https" \
      --label "traefik.http.routers.osmtileserver.middlewares=osmtileserver-https-redirect" \
      --label "traefik.http.routers.osmtileserver-secure.entrypoints=https" \
      --label "traefik.http.routers.osmtileserver-secure.rule=Host(\`t2.openseamap.org\`)" \
      --label "traefik.http.routers.osmtileserver-secure.tls=true" \
      --label "traefik.http.routers.osmtileserver-secure.tls.certresolver=http" \
      --label "traefik.http.routers.osmtileserver-secure.service=osmtileserver" \
      --label "traefik.http.services.osmtileserver.loadbalancer.server.port=80" \
      --label "traefik.docker.network=proxy" \
      --label  "traefik.http.routers.osmtileserver.middlewares=cors-headers@docker" \
      --label  "traefik.http.middlewares.cors-headers.headers.accessControlAllowOriginList=*" \
      --label  "traefik.http.middlewares.cors-headers.headers.accessControlAllowHeaders=Origin, X-Requested-With, Content-Type, Accept, Authorization" \
      --label  "traefik.http.middlewares.cors-headers.headers.accessControlAllowMethods=GET, POST, PUT, DELETE, OPTIONS" \
      --network proxy $IMAGE_NAME \
      run 
}

# --publish 8001:80

function stop() {
  docker container stop $IMAGE_NAME
  docker container rm $IMAGE_NAME
}

function build() {
  docker build -t $IMAGE_NAME ./src
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    build
    stop
    start
    ;;
  build)
    build
	;;
  connect)
		docker exec -i -t $IMAGE_NAME /bin/bash
	;;
  log)
		docker logs -f $IMAGE_NAME
	;;
  *)
	echo "Usage: docker.service.sh {start|stop|restart|build|connect|log}" >&2
	exit 1
	;;
esac

exit 0
