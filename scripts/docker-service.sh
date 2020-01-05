#!/bin/bash

# start and stops the osm tile server

set -x

IMAGE_NAME="osm-tileserver"

HOSTNAME=$(cat /etc/hostname)

if  [ $HOSTNAME == "stone" ]
  then
    WEBSERVERPORT=8001
  else
    WEBSERVERPORT=80
fi

function start() {
  docker run \
      --name $IMAGE_NAME \
      --rm=false \
      --detach \
      --hostname osmtileserver \
      --link osm-tileserver-db:osm-tileserver-db \
      --shm-size=6G \
      --publish $WEBSERVERPORT:80 \
      -v $PWD/volumes/transfer:/transfer \
      -v openstreetmap-tilecache:/var/lib/mod_tile \
      $IMAGE_NAME \
      run
}

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
